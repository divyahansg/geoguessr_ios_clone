//
//  CoreDataStore.m
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/19/14.
//  Adapted from: http://robots.thoughtbot.com/core-data
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//

#import "CoreDataStore.h"
#import <CoreData/CoreData.h>
#import "Score.h"

@interface CoreDataStore ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;

@end

@implementation CoreDataStore


#pragma mark - Singleton Access

+ (CoreDataStore *)defaultStore
{
    static CoreDataStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[self alloc] init];
    });
    return defaultStore;
}

+ (NSManagedObjectContext *)mainQueueContext
{
    return [[self defaultStore] mainQueueContext];
}

+ (NSManagedObjectContext *)privateQueueContext
{
    return [[self defaultStore] privateQueueContext];
}

#pragma mark - Getters

- (NSManagedObjectContext *)mainQueueContext
{
    if (!_mainQueueContext) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _mainQueueContext;
}

- (NSManagedObjectContext *)privateQueueContext
{
    if (!_privateQueueContext) {
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _privateQueueContext;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        NSString *path = [self modelPath];
        NSURL *storeUrl = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSavePrivateQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[self privateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSaveMainQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[self mainQueueContext]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.mainQueueContext performBlock:^{
            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.privateQueueContext performBlock:^{
            [self.privateQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (NSString *) modelPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"GeoGuesserStore.data"];
}

- (NSManagedObjectID *) createScore: (NSNumber *)score
{
    __block Score *u = nil;
    __block NSError *error = nil;
    [[self privateQueueContext] performBlockAndWait:^{
        u = [NSEntityDescription insertNewObjectForEntityForName:@"Score"
                                          inManagedObjectContext: [self privateQueueContext]];
        u.number = score;
        u.date = [NSDate date];
        [[self privateQueueContext] save:&error];
    }];
    return u.objectID;
}

- (NSArray *)retrieveScores
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Score" inManagedObjectContext:[self privateQueueContext]];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    req.sortDescriptors = @[sd];
    __block NSError *error;
    __block NSMutableArray *ids = [[NSMutableArray alloc] init];
    [[self privateQueueContext] performBlockAndWait:^{
        NSArray *result = [[self privateQueueContext] executeFetchRequest:req error:&error];
        NSLog(@"ids count = %lu", (unsigned long)[result count]);
        for(NSManagedObject *obj in result) {
            [ids addObject:[obj objectID]];
        }
    }];
    return ids;
}

@end

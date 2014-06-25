//
//  CoreDataStore.h
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/19/14.
//  Adapted from: http://robots.thoughtbot.com/core-data
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//
#import "CoreDataStore.h"
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
@class Score;


@interface CoreDataStore : NSObject

+ (NSManagedObjectContext *)mainQueueContext;
+ (NSManagedObjectContext *)privateQueueContext;

+ (CoreDataStore *)defaultStore;


- (NSManagedObjectID *) createScore: (NSNumber *)score;
- (NSArray *)retrieveScores;



@end

//
//  HomeViewController.m
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/24/14.
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//

#import "HomeViewController.h"
#import "MapViewController.h"
#import "ScoreTableViewCell.h"

#import <CoreData/CoreData.h>
#import "CoreDataStore.h"
#import "Score.h"


@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UITableView *scoresTable;

@property (strong, nonatomic) NSMutableArray *scores;

@end

@implementation HomeViewController


- (id)init
{
    self = [super init];
    
    self.scores = [[NSMutableArray alloc] init];
    NSArray *retrievedScores = [[CoreDataStore defaultStore] retrieveScores];
    for (NSManagedObjectID *id in retrievedScores) {
        Score *s = (Score *)[[CoreDataStore mainQueueContext] objectWithID:id];
        [self.scores addObject:s];
    }
    
    [self.scores sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Score *score1 = (Score *)obj1;
        Score *score2 = (Score *)obj2;
        return [score1.number compare:score2.number];
    }];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(scoreTableDidChange:)
     name: NSManagedObjectContextObjectsDidChangeNotification
     object: [CoreDataStore mainQueueContext]];
    
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)playButtonPressed:(id)sender {
    MapViewController *mvc = [[MapViewController alloc] init];
    mvc.title = @"Play";
    
    [self.navigationController pushViewController:mvc animated:YES];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.scoresTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.scores count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreTableViewCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ScoreTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    Score *s = self.scores[indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yy"];
    
    
    
    NSString *formattedDate = [dateFormat stringFromDate:s.date];
    NSString *formattedToday = [dateFormat stringFromDate:[NSDate date]];
    if([formattedDate isEqualToString:formattedToday]) {
        cell.dateLabel.text = @"Today";
    } else {
        cell.dateLabel.text = [NSString stringWithFormat:@"%@", formattedDate];
    }
    
    cell.rankLabel.text = [NSString stringWithFormat:@"%lu", indexPath.row +1];
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    [numFormat setMaximumFractionDigits:3];
    NSString *formattedScore = [numFormat stringFromNumber:s.number];
    NSString *text = [formattedScore stringByAppendingString:@" mi."];
    
    NSMutableAttributedString *attributedstring = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedstring addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:15.0]
                             range:[text rangeOfString:@"mi."]];
   
    cell.numberLabel.attributedText = attributedstring;
    
    return cell;
}

- (void) scoreTableDidChange: (NSNotification *) notification
{
    NSArray *inserted = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    for (Score *s in inserted) {
        NSLog(@" inserted %@", s.number);
        [self.scores addObject:s];
    }

    [self.scores sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Score *score1 = (Score *)obj1;
        Score *score2 = (Score *)obj2;
        return [score1.number compare:score2.number];
    }];
    
    [self.scoresTable reloadData];
}
@end

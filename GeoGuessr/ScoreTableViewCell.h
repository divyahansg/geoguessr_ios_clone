//
//  ScoreTableViewCell.h
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/24/14.
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

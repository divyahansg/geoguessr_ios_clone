//
//  AnswerViewController.m
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/24/14.
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//

#import "AnswerViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreData/CoreData.h>
#import "CoreDataStore.h"

@interface AnswerViewController () <GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong, nonatomic) CLLocation *correct;
@property (strong, nonatomic) CLLocation *guess;
@property (strong, nonatomic) NSNumber *score;

@end

@implementation AnswerViewController

- (id)initWithCorrectLocation:(CLLocation *)correct andGuessLocation:(CLLocation *)guess
{
    
    self = [self initWithNibName:@"AnswerViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        self.correct = correct;
        self.guess = guess;
    
        CLLocationDistance dist = [correct distanceFromLocation:guess];
    
        self.score = [NSNumber numberWithDouble:(dist * 0.000621371)];
        [[CoreDataStore defaultStore] createScore:self.score];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    GMSMapView *answerSubView = [[GMSMapView alloc] initWithFrame:self.mapView.bounds];
    
    answerSubView.mapType = kGMSTypeNormal;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.guess.coordinate.latitude
                                                            longitude:self.guess.coordinate.longitude
                                                                 zoom:1];
    answerSubView.camera  = camera;
    answerSubView.delegate = self;
    
    GMSMarker *correctMarker = [[GMSMarker alloc] init];
    [correctMarker setIcon:[GMSMarker markerImageWithColor:[UIColor greenColor]]];
    [correctMarker setMap:answerSubView];
    [correctMarker setPosition:self.correct.coordinate];
    
    GMSMarker *guessMarker = [[GMSMarker alloc] init];
    [guessMarker setMap:answerSubView];
    [guessMarker setPosition:self.guess.coordinate];
    
    GMSMutablePath *path = [[GMSMutablePath alloc] init];
    [path addCoordinate:self.correct.coordinate];
    [path addCoordinate:self.guess.coordinate];
    GMSPolyline *line = [GMSPolyline polylineWithPath:path];
    [line setMap:answerSubView];
    
    [self.mapView addSubview:answerSubView];
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    [numFormat setMaximumFractionDigits:3];
    NSString *formattedScore = [numFormat stringFromNumber:self.score];
    NSString *text = [formattedScore stringByAppendingString:@"mi."];
    
    NSMutableAttributedString *attributedstring = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedstring addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:25.0]
                             range:[text rangeOfString:@"mi."]];
    [attributedstring addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkGrayColor]
                             range:[text rangeOfString:@" mi."]];
    self.scoreLabel.attributedText = attributedstring;
    
}



@end

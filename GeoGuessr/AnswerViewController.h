//
//  AnswerViewController.h
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/24/14.
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>


@interface AnswerViewController : UIViewController

- (id) initWithCorrectLocation:(CLLocation *)correct andGuessLocation:(CLLocation *)guess;

@end

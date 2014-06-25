//
//  MapViewController.m
//  GeoGuessr
//
//  Created by Divyahans Gupta on 6/23/14.
//  Copyright (c) 2014 Divyahans Gupta. All rights reserved.
//

#import "MapViewController.h"
#import "AnswerViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreData/CoreData.h>
#import "CoreDataStore.h"


@interface MapViewController () <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *streetView;
@property (weak, nonatomic) IBOutlet UIView *guessView;

@property GMSPanoramaView *GMSstreetView;
@property GMSMarker *marker;
@property CLLocationCoordinate2D correctLoc;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation MapViewController

 - (id)init
{
    self = [self initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]];
    if(self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(finalizeLocation:)];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self initializeGame];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if(self.marker) {
        [self.marker setPosition:coordinate];
    }
    else {
        self.marker = [GMSMarker markerWithPosition:coordinate];
        self.marker.map = mapView;
    }
}

- (void) finalizeLocation: (id)sender
{
    if(self.marker) {
        CLLocation *guessloc = [[CLLocation alloc] initWithLatitude:self.marker.position.latitude longitude:self.marker.position.longitude];
        CLLocation *answerloc = [[CLLocation alloc] initWithLatitude:self.correctLoc.latitude longitude:self.correctLoc.longitude];
        
        AnswerViewController *answer = [[AnswerViewController alloc] initWithCorrectLocation:answerloc andGuessLocation:guessloc];
        answer.title = @"Score";
        
        [self.marker.map clear];
        self.marker = nil;
        
        [self initializeStreetView];
        
        [self.navigationController pushViewController:answer animated:YES];
        
    } else {
        UIAlertView *noMarker = [[UIAlertView alloc] initWithTitle:@"Pick a location" message:@"Tap on the map to guess a location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noMarker show];
    }
}

- (void) initializeGame
{
    [self.spinner startAnimating];
    
    [self initializeStreetView];
    [self initializeMapView];
    
    [self.spinner stopAnimating];
}

- (void) initializeStreetView
{
    srand48(time(0));
    double lat = 35 + (drand48() * ((40 - 32) + 1));
    double lng = -120 + (drand48() * ((-80 + 120) + 1));
    

    GMSPanoramaService *service = [[GMSPanoramaService alloc] init];
    [service requestPanoramaNearCoordinate:CLLocationCoordinate2DMake(lat, lng) callback:^(GMSPanorama *panorama, NSError *error) {
        if(!panorama) {
            [self initializeStreetView];
        } else {
            self.GMSstreetView = [[GMSPanoramaView alloc] initWithFrame:self.streetView.bounds];
            GMSPanoramaCamera *camera = [GMSPanoramaCamera cameraWithHeading:180 pitch:0 zoom:1];
            self.GMSstreetView.camera = camera;
            self.GMSstreetView.panorama = panorama;
            self.GMSstreetView.streetNamesHidden = YES;
            self.correctLoc = panorama.coordinate;
            [self.streetView addSubview:self.GMSstreetView];
        }
    }];
}

- (void) initializeMapView
{

    GMSMapView *guessSubView = [[GMSMapView alloc] initWithFrame:self.guessView.bounds];
    
    guessSubView.mapType = kGMSTypeNormal;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.6
                                                            longitude:-95.665
                                                                 zoom:1];
    guessSubView.camera  = camera;
    guessSubView.delegate = self;
    
    [self.guessView addSubview:guessSubView];
}

@end

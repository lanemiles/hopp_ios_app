//
//  MapViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/14/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController ()

//CLLocationManager used to get GPS level data when view is open and background data when view is not visible
@property (strong, nonatomic) CLLocationManager *locationManager;

//GMSMapView is the google maps view that we display our data on
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    //first, we initialize the location manager and set its preferences
    //note that we don't start updating location in viewdidload
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    
    //the GMS map view is initialized from storyboards
    
}

//
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

//
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

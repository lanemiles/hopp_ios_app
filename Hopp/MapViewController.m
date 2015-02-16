//
//  MapViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/14/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UserDetails.h"

@interface MapViewController () <GMSMapViewDelegate>

//CLLocationManager used to get GPS level data when view is open and background data when view is not visible
@property (strong, nonatomic) CLLocationManager *locationManager;

//GMSMapView is the google maps view that we display our data on
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

//spinner view for while we get network data
@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;

//our user object for getting properties
@property (strong, nonatomic) UserDetails *userDetails;

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
    
    //we get approval to use user location even while in the background
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    //the GMS map view is initialized from storyboards
    //but we need to set its properties
    //Controls the type of map tiles that should be displayed.
    _mapView.mapType = kGMSTypeNormal;
    //Shows the compass button on the map
    _mapView.settings.compassButton = NO;
    //Shows the my location button on the map
   _mapView.settings.myLocationButton = NO;
    //Sets the view controller to be the GMSMapView delegate
   _mapView.delegate = self;
    
    //initialize the spinner view
    _spinnerView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinnerView setBackgroundColor:[UIColor blackColor]];
    [_spinnerView setAlpha:.60];
    [_spinnerView setFrame:CGRectMake(0, 0, 75, 75)];
    [_spinnerView.layer setCornerRadius:20.0];
    _spinnerView.center=self.view.center;
    _spinnerView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    [self.view addSubview:_spinnerView];
    
    //create our user object
    _userDetails = [[UserDetails alloc] initWithDeviceID: [UIDevice currentDevice].identifierForVendor.UUIDString];
    
}


//we don't want to make any network calls here as that can cause latency issues
    //TODO: if we do asynch network calls does that matter? can we start those here?
//we center ourselves on the 5Cs
//we turn enable my location on GMS
//we turn on our loading spinner
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //center the 5Cs
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(34.094764, -117.716715);
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(34.106765, -117.703073);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:sw coordinate:ne];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:15.0f];
    [_mapView animateWithCameraUpdate:update];
    [_mapView animateToBearing:1];
    
    //turn on myLocation
    _mapView.myLocationEnabled = YES;
    
    //turn on spinner
    [_spinnerView startAnimating];
    
}

//we want to make our network calls here
    //update location to server
    //get new pins
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
}

//we want to stop getting constant location udpates
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    //turn off constant updating
    _mapView.myLocationEnabled = NO;
    
}

//this is called from the app delegate when we enter the background
- (void) stopConstantUpdates {
    
    [_spinnerView stopAnimating];
    
}


#pragma mark - Network Calls







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

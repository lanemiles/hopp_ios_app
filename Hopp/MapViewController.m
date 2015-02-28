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
#import <CoreLocation/CoreLocation.h>
#import "UserDetails.h"
#import <QuartzCore/QuartzCore.h>
#import "OBShapedButton.h"
#import "PartyDetailsTableViewController.h"

@interface MapViewController () <GMSMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate>

//CLLocationManager used to get GPS level data when view is open and background data when view is not visible
@property (strong, nonatomic) CLLocationManager *locationManager;

//GMSMapView is the google maps view that we display our data on
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

//spinner view for while we get network data
@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;

//our user object for getting properties
@property (strong, nonatomic) UserDetails *userDetails;

//boolean used to check if we are visible
@property BOOL viewIsVisible;

//this is what we use to store the results of our asynch url request
@property (strong, nonatomic) NSMutableData *responseData;

//so we can go from outline to marker tap
@property (nonatomic, strong) NSMutableDictionary *overlayToMarker;

//so we have all of our information about our parties
@property (nonatomic, strong) NSMutableDictionary *partyInformation;


@end

@implementation MapViewController
#pragma mark-
#pragma mark View Controller Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    //first, we initialize the location manager and set its preferences
    //note that we don't start updating location in viewdidload
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.distanceFilter = 0.0;
    _locationManager.delegate = self;
    
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
    _mapView.settings.myLocationButton = YES;
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
    
    //also register for the notifications that we are going to want to listen for
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(postNewLocation:)
                                                 name:@"MapViewControllerShouldPostNewLocation"
                                               object:nil];
    
    
    //instantiate our user singleton
    [UserDetails currentUser];
    
    //initialize party infomation dictionary
    _partyInformation = [[NSMutableDictionary alloc] init];
    
}


//we don't want to make any network calls here as that can cause latency issues
//TODO: if we do asynch network calls does that matter? can we start those here?
//we center ourselves on the 5Cs
//we turn enable my location on GMS
//we turn on our loading spinner
//style our navigation controller
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    //center the 5Cs
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(34.094764, -117.716715);
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(34.106765, -117.703073);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:sw coordinate:ne];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:15.0f];
    [_mapView animateWithCameraUpdate:update];
    [_mapView animateToBearing:1];
    
    //set view active to yes
    _viewIsVisible = YES;
    
    //turn on myLocation
    _mapView.myLocationEnabled = YES;
    
    //turn on location updates
    [_locationManager startUpdatingLocation];
    
    //turn on spinner
    [_spinnerView startAnimating];
    
    //style our nav/tab controller
    [self styleNavigationController];
    [self styleTabBarController];
    
}

//we want to make our network calls here
//update location to server
//get new pins
//check if we are logged in (this cannot happen in VWA)
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //first, check on logged in status
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"] == false) {
        [self.tabBarController performSegueWithIdentifier:@"Login" sender:self.tabBarController];
    } else {
        [[UserDetails currentUser] getUserDetails];
    }
    
    
    
    //send off our request to get markers
    [self getPartyLocationMarkers];
    
}

//we want to stop getting constant location udpates
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    //turn off constant updating
    [self stopConstantUpdates];
    
}


#pragma mark-
#pragma mark Network Calls
- (void) getPartyLocationMarkers {
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/getPartyLocationData.php"]]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark-
#pragma mark Notification Methods
- (void) postNewLocation: (NSNotification *) notification {
    [_locationManager startUpdatingLocation];
    
}
#pragma mark-
#pragma mark GPS Methods
//this is called from the app delegate when we enter the background
- (void) stopConstantUpdates {
    _mapView.myLocationEnabled = NO;
    [_locationManager stopUpdatingLocation];
    //set view is active to no
    _viewIsVisible = NO;
}

//this is called every time we get a new location from the CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (_viewIsVisible) {
        
        //if we're visible, we want to update every time we get a new location
        [[UserDetails currentUser] updateUserLocationWithCoordinate:newLocation];
        
        //and we also want to update the map
        [self getPartyLocationMarkers];
        
    } else {
        
        //if here, our view is not visible and we should just get a single location update and post an update
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewControlledDidPostNewLocation"
                                                            object:nil userInfo:[[NSDictionary alloc] initWithObjects: [NSArray arrayWithObject:newLocation] forKeys:[NSArray arrayWithObject:@"Location"]]];
        
        //and then stop updating the location
        [_locationManager stopUpdatingLocation];
        
    }
    
    
    
}
#pragma mark - GMS Delegate / Map Display Methods

- (void) stopRefreshControl {
    [_spinnerView stopAnimating];
}

- (BOOL) mapView: (GMSMapView *) mapView  didTapMarker:(GMSMarker *)marker {
    CGPoint point = [_mapView.projection pointForCoordinate:marker.position];
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[_mapView.projection coordinateForPoint:point]];
    [_mapView animateWithCameraUpdate:camera];
    
    
    
    GMSCameraUpdate *update1 = [GMSCameraUpdate zoomTo:19];
    [_mapView animateWithCameraUpdate:update1];
    [_mapView animateToBearing:1];
    return NO;
}

- (void) centerMarker: (GMSMarker *) marker {
    GMSCameraUpdate *update1 = [GMSCameraUpdate zoomTo:19];
    [_mapView animateWithCameraUpdate:update1];
    CGPoint point = [_mapView.projection pointForCoordinate:marker.position];
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[_mapView.projection coordinateForPoint:point]];
    [_mapView animateWithCameraUpdate:camera];
    
    [_mapView animateToBearing:1];
}



- (IBAction)wasTapped:(OBShapedButton *)sender {
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(34.094764, -117.716715);
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(34.106765, -117.703073);
    GMSCoordinateBounds *bounds =
    [[GMSCoordinateBounds alloc] initWithCoordinate:sw coordinate:ne];
    
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:15.0f];
    [_mapView animateWithCameraUpdate:update];
    [_mapView animateToBearing:1];
}

- (BOOL) didTapMyLocationButtonForMapView: (GMSMapView *) mapView {
   
    return NO;
}

- (void) addDarkOverlay {
    
    //to make our dark overlay, we just do a big overlay with a dark bg and medium opacity?
    //TODO: do this better
    GMSMutablePath *other = [GMSMutablePath path];
    [other addCoordinate:CLLocationCoordinate2DMake(34.110484, -117.724027)];
    [other addCoordinate:CLLocationCoordinate2DMake(34.111092, -117.689668)];
    [other addCoordinate:CLLocationCoordinate2DMake(34.084754, -117.686852)];
    [other addCoordinate:CLLocationCoordinate2DMake(34.085567, -117.732380)];
    [other addCoordinate:CLLocationCoordinate2DMake(34.110484, -117.724027)];
    // Create the polygon, and assign it to the map.
    GMSPolygon *otherPolygon = [GMSPolygon polygonWithPath:other];
    float valNum = (20.0/255);
    otherPolygon.fillColor = [UIColor colorWithRed:valNum green:valNum blue:valNum alpha:.5];
    otherPolygon.zIndex = 0;
    otherPolygon.map = _mapView;
    otherPolygon.tappable = NO;
    
}


- (void) mapView:(GMSMapView *) mapView didTapInfoWindowOfMarker:(GMSMarker *) marker {
    [self performSegueWithIdentifier:@"PartyDetailsSegue" sender:marker];
}


#pragma mark-
#pragma mark Background Location Update Methods
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //since we need to do things on our own, we create our own manager
    CLLocationManager *backgroundManager = [[CLLocationManager alloc] init];
    backgroundManager.delegate = self;
    backgroundManager.distanceFilter = 0;
    backgroundManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [backgroundManager startUpdatingLocation];
    [self getUpdateWithManager: backgroundManager AndHandler:completionHandler];
    
}

//now we have our manager, and we recurse until we get a location
//TODO: This is bad, but how to do better?
- (void) getUpdateWithManager: (CLLocationManager *)temp AndHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //if we have a location
    if (temp.location != nil) {
        
        //update user location
        [[UserDetails currentUser] backgroundUserLocationUpdateWithCoordinate:temp.location];
        
        //stop getting locations
        [temp stopUpdatingLocation];
        
        //free the space?
        temp = nil;
        
        //return back and go back to background
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else {
        
        //else, try again
        [self getUpdateWithManager: temp AndHandler:completionHandler];
    }
    
}


//TODO: Matt, here is another place we want you to get started implementing the design.
    //We want to override the custom markerInfoWindow (the view that appears when you tap on a marker on the map)
    //I'm not sure what the best way to do this is, but I did it last time by initializing a UIView from a XIB I created
    //To get information about a party (num people, etc), you can get a dictionary of data by accessing _partyInformation where the key is marker.title.
/*
-(UIView *)mapView:(GMSMapView *) aMapView markerInfoWindow:(GMSMarker*) marker {

 
}
*/



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //now, let's check to see what request we just successfully completed
    NSString *urlString = connection.currentRequest.URL.absoluteString;
    
    //first, we check if we just updated details
    if ([urlString rangeOfString:@"getPartyLocationData"].location == NSNotFound) {
        
    }
    
    //if here, we just get new party data
    else {
        NSError* error;
        NSArray* json = [[NSJSONSerialization JSONObjectWithData:_responseData
                                                         options:kNilOptions
                                                           error:&error] objectForKey:@"Data"];
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //remove all of the map overlays
                [self.mapView clear];
                
                //add back school outlines
                [self addDarkOverlay];
                
                //iterate through locations
                for (NSDictionary *dict in json) {
                    
                    //get properties from JSON
                    NSString *name = [dict valueForKey:@"Name"];
                    NSString *numPeople = [dict valueForKey:@"NumPeople"];
                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake( [[dict valueForKey:@"Latitude"] doubleValue], [[dict valueForKey:@"Longitude"] doubleValue]);
                    
                    //make the GMS marker
                    GMSMarker *marker = [GMSMarker markerWithPosition:position];
                    marker.title = name;
                    marker.snippet = numPeople;
                    marker.map = _mapView;
                    //marker.infoWindowAnchor = CGPointMake(.44f, -0.075f);
                    
                    //add this information to party information
                    [_partyInformation setObject:dict forKey:marker.title];
                    
                    //make the building outline
                    GMSMutablePath *path = [GMSMutablePath path];
                    NSArray *locs = [dict valueForKey:@"Outline"];
                    for (NSDictionary *locPair in locs) {
                        CLLocationCoordinate2D position = CLLocationCoordinate2DMake( [[locPair valueForKey:@"Latitude"] doubleValue], [[locPair valueForKey:@"Longitude"] doubleValue]);
                        [path addCoordinate:position];
                    }
                    GMSPolygon *outline = [GMSPolygon polygonWithPath:path];
                    outline.strokeWidth = 2;
                    outline.map = _mapView;
                    
                    
                    //set the marker and outline color properties
                    if ([[dict valueForKey:@"NumPeople"] doubleValue] > 0) {
                        marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:1.0 green:0 blue:0.0 alpha:1.0]];
                        marker.zIndex = 100;
                        outline.fillColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:.3];
                        outline.strokeColor = [UIColor colorWithRed:1.00 green:0 blue:0 alpha:1];
                        
                    } else {
                        marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:0 green:0 blue:1.0 alpha:1.0]];
                        marker.zIndex=10;
                        outline.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:.3];
                        outline.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
                    }
                    outline.title = name;
                    [outline setTappable:YES];
                    [_overlayToMarker setObject:marker forKey:name];
                    
                    //and we want to stop spinning
                    [self performSelector:@selector(stopRefreshControl) withObject:nil afterDelay:.75];
                    
                    
                    
                    
                }
                
            });
            
        }
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%@", error);
}

#pragma mark - Tab and Nav Bar Styling
- (void) styleNavigationController {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:.85 green:.1 blue:0 alpha:1]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      
      [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22.0],
      NSFontAttributeName,
      nil]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}
- (void) styleTabBarController {
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:.85 green:.1 blue:0 alpha:1];
}


#pragma mark - Navigation Methods

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    _viewIsVisible = NO;
    
    //check if seguing to a party detail TVC
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {

        UINavigationController *navController = [segue destinationViewController];
        PartyDetailsTableViewController *new = (PartyDetailsTableViewController *)([navController viewControllers][0]);
        if ([sender isKindOfClass:[GMSMarker class]]) {
            
            GMSMarker *temp = (GMSMarker*) sender;
            new.seguePartyName = temp.title;
        }
        
        
        
    } else {
        
        PartyDetailsTableViewController *new = (PartyDetailsTableViewController *)segue.destinationViewController;
        if ([sender isKindOfClass:[GMSMarker class]]) {
            
            GMSMarker *temp = (GMSMarker*) sender;
            
            new.seguePartyName = temp.title;
        }
    }
    
}


@end

//
//  UserDetails.m
//  Hopp
//
//  Created by Lane Miles on 2/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "UserDetails.h"
#import <CoreLocation/CoreLocation.h>

@interface UserDetails () <NSURLConnectionDelegate>

//this is what we use to store the results of our asynch url request
@property (strong, nonatomic) NSMutableData *responseData;

//these will be set after the request
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *currentPartyName;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *lastUpdated;

@end


@implementation UserDetails 

//whenever we create this object, we want to gather data based off the IDforVendor
- (id)initWithDeviceID: (NSString *)deviceID {
    self = [super init];
    if (self) {
        _userID = [deviceID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

#pragma mark - Get and Set User Details


//get user details from server
- (void) getUserDetails {
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/getUserInfo.php?userID=%@", _userID]]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

//update user location
- (void) updateUserLocationWithCoordinate: (CLLocation*) newLocation {
    
    //create request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/updateUserLocation.php?userID=%@&latitude=%f&longitude=%f", _userID, newLocation.coordinate.latitude, newLocation.coordinate.longitude]]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark NSURLConnection Delegate Methods

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
    if ([urlString containsString:@"getUserInfo"]) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            //if we don't have an error in reading the JSON, let's set our instance variables
            _currentPartyName = [json objectForKey:@"placeName"];
            _fullName = [json objectForKey:@"fullName"];
            _firstName = [json objectForKey:@"shortName"];
            _latitude = [json objectForKey:@"latitude"];
            _longitude = [json objectForKey:@"longitude"];
            _lastUpdated = [json objectForKey:@"time"];
            _gender = [json objectForKey:@"gender"];
            
        }
        
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%@", error);
}

@end

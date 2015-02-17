//
//  UserDetails.m
//  Hopp
//
//  Created by Lane Miles on 2/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "UserDetails.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface UserDetails () <NSURLConnectionDelegate>

//this is what we use to store the results of our asynch url request
@property (strong, nonatomic) NSMutableData *responseData;

@end


@implementation UserDetails 

//whenever we create this object, we want to gather data based off the IDforVendor
- (id)init {
    self = [super init];
    if (self) {
        _userID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    }
    return self;
}

#pragma mark-Static Getter
static UserDetails *currentUser = nil;

+ (UserDetails *)currentUser {
    if (currentUser == nil) {
        currentUser = [[self alloc] init];
    }
    return currentUser;
}

#pragma mark -Network Methods


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

- (void) backgroundUserLocationUpdateWithCoordinate: (CLLocation*) newLocation {
    //create request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/updateUserLocation.php?userID=%@&latitude=%f&longitude=%f", _userID, newLocation.coordinate.latitude, newLocation.coordinate.longitude]]];
    
    // Create url connection and fire request
    // Send a synchronous request
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error != nil) {
        NSLog(@"ERROR");
    } else {
        NSLog(@"Background location updated");
    }

    
}

- (void) registerUserWithLongName: (NSString *)longName andShortName: (NSString *)shortName andGender: (NSString *)gender andLocation: (CLLocation *)location {
    
    //we build up our URL
    NSString *url = [NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/addUser.php?userID=%@&gender=%@&longName=%@&shortName=%@&latitude=%f&longitude=%f", _userID,gender,longName,shortName,location.coordinate.latitude,location.coordinate.longitude];

    //encode it
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //create the request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
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
    
    //first, we check if we just updated details, if here, we didn't
    if ([urlString rangeOfString:@"getUserInfo"].location == NSNotFound) {
        
        //so we get user details after an udpate
        [self getUserDetails];
        
    }
    
    //if here, we just updated user details and want to update local
    else {
        
            NSError* error;
            NSDictionary* json = [[NSJSONSerialization JSONObjectWithData:_responseData
                                                                  options:kNilOptions
                                                                    error:&error] objectForKey:@"Data"];
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

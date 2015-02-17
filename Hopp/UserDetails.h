//
//  UserDetails.h
//  Hopp
//
//  Created by Lane Miles on 2/15/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UserDetails : NSObject

//singleton static getter
+ (id)currentUser;

//network methods
- (void) getUserDetails;
- (void) updateUserLocationWithCoordinate: (CLLocation*) newLocation;
- (void) registerUserWithLongName: (NSString *)longName andShortName: (NSString *)shortName andGender: (NSString *)gender andLocation: (CLLocation *)location;
- (void) backgroundUserLocationUpdateWithCoordinate: (CLLocation*) newLocation;


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

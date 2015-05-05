//
//  MapViewController.h
//  Hopp
//
//  Created by Lane Miles on 2/14/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property(strong, nonatomic) NSArray *jsonArray;

//this is called by the app delegate on backgrounding
- (void) stopConstantUpdates;

//this is called by delegate for silent push notifications
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

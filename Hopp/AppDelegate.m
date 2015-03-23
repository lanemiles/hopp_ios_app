//
//  AppDelegate.m
//  Hopp
//
//  Created by Lane Miles on 2/11/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MapViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //set up Parse
    [Parse setApplicationId:@"0UW66oQJdG531qkgHXNjhcPRceTeVHG8hplMedDk"
                  clientKey:@"mg9Pb71oXdd59XhgKVM6FckA60TSG8a62vo07qDH"];
    
    
    //register for push notifications from Parse
    //this handles ios 7 and 8
    
    /*
     
     XCODE SAYS THIS CODE IS NOT NEEDED
     TODO: can we remove this?
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    */
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    //setup facebook SDK
    [FBLoginView class];
    
    //setup google maps SDK
    [GMSServices provideAPIKey:@"AIzaSyBN_Z1R0jbc2Vf6G0jdY-K8BRGsYWumEwM"];
    
    
    return YES;
}

//setting up to receive background notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

//default Parse push notification handler
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

//overriding the default handler, so that we can deal with silent notifications in the background
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    //to handle the silent notification, we do things not asynch, but sync because of time constraints and the handler

    //so we get our controller
    MapViewController* mainController = (MapViewController*)  [[[[((UITabBarController *)self.window.rootViewController) viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    [mainController fetchNewDataWithCompletionHandler:handler];
    
    //Success
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //we want to stop the constant GPS updating if this happens from the MapViewController
    MapViewController* mapVC = (MapViewController*)  [[[[((UITabBarController *)self.window.rootViewController) viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    [mapVC stopConstantUpdates];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //when we enter the foreground, let's make sure if we are going back to the mapview we turn back on constant updating
    //if we are loading into the mapVC, turn it back on
    
    //get map VC
     MapViewController* mapVC = (MapViewController*)  [[[[((UITabBarController *)self.window.rootViewController) viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    //start the spinner, which we can accomplish by making this as if its a regular view will appear
    if (mapVC.isViewLoaded && mapVC.view.window) {
        [mapVC viewWillAppear:YES];
        [mapVC viewDidAppear:YES];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//facebook login methods
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}



@end

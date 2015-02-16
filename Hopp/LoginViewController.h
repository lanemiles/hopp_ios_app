//
//  LoginViewController.h
//  Hopp
//
//  Created by Lane Miles on 2/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController

//our login button
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

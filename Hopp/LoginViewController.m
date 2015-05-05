//
//  LoginViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "LoginViewController.h"
#import "UserDetails.h"

@interface LoginViewController ()  <FBLoginViewDelegate>

@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) id facebookUserDetails;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //get basic facebook data from SDK
    self.loginView.readPermissions = @[@"public_profile"];
    
    //register for the notifications we are going to receive
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNewLocation:)
                                                 name:@"MapViewControlledDidPostNewLocation"
                                               object:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-Notification Methods
- (void) receivedNewLocation: (NSNotification *) notification {
    
    //we set logged in to true
  //   NSLog(@"Got notification and value is: %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]);
   
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"] == true) {
        
    } else {
        
    
        //if we aren't logged in, let's get the location
        NSDictionary *temp = notification.userInfo;
        _lastLocation = [temp objectForKey:@"Location"];
        
        //now let's register the user
        [self registerUser];
        
        //mark us as logged in
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"loggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //and go away
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


#pragma mark-Facebook Delegate Methods

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
   //  NSLog(@"Logged in via FB");
    
    //if they successfully login via facebook, we want to get a location, register them, and never do that again
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewControllerShouldPostNewLocation"
                                                        object:nil userInfo:nil];
    
    //set our variable so we can register with these details later
    _facebookUserDetails = user;

    
}

- (void) registerUser {
    
    //call the relevant method on our user
    [[UserDetails currentUser] registerUserWithLongName: [_facebookUserDetails objectForKey:@"name"] andShortName: [_facebookUserDetails objectForKey:@"first_name"] andGender: [_facebookUserDetails objectForKey:@"gender"] andLocation: _lastLocation];
}

/*
#pragma mark -Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

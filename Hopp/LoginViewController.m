//
//  LoginViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/16/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()  <FBLoginViewDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //get basic facebook data from SDK
    self.loginView.readPermissions = @[@"public_profile"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Facebook Delegate Methods

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    //first we register on our servers
        //TODO: Get a location
        //TODO: Register the user
    
    //then we set logged in to true
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"loggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //then we go away
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) registerUser {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

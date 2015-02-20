//
//  AddMessageTableViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/19/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "AddMessageTableViewController.h"

@interface AddMessageTableViewController ()

//label for location and time
@property (strong, nonatomic) IBOutlet UILabel *locationTimeLabel;

//textfield for message body
@property (strong, nonatomic) IBOutlet UITextView *messageBodyTextField;

@end

@implementation AddMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

//here, we want to get the user's information
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //TODO: update user location first...tough b/c CLLocationManager is in MapViewController
    
    //get user location from UserDetails
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bar Button Interaction Methods
//if here, we want to tell the news feed to post a comment on the user's behalf
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
}

//if here, we need to dismiss ourselves
- (IBAction)cancelButtonPushed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextField Delegate Methods
//so we can cap characters
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return textView.text.length + (text.length - range.length) <= 140;
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

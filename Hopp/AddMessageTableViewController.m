//
//  AddMessageTableViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/19/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "AddMessageTableViewController.h"
#import "UserDetails.h"
#import "NewsFeed.h"

@interface AddMessageTableViewController ()

//label for location and time
@property (strong, nonatomic) IBOutlet UILabel *locationTimeLabel;

//textfield for message body
@property (strong, nonatomic) IBOutlet UITextView *messageBodyTextField;

@end

@implementation AddMessageTableViewController

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //style our nav bar
    [self styleNavigationController];
    
    //register for the notifications we will receive from the News Feed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSendMessage:)
                                                 name:@"NewsFeedDidSendMessage"
                                               object:nil];
    
}

//here, we want to get the user's information
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //TODO: update user location first...tough b/c CLLocationManager is in MapViewController
    
    //get user location from UserDetails
    NSString *userLocation = [[UserDetails currentUser] currentPartyName];
    
    //get time
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *time = [dateFormatter stringFromDate: currentTime];
    
    //set the label
    _locationTimeLabel.text = [NSString stringWithFormat:@"%@ @ %@", userLocation, time];

    //set the placeholder text
    _messageBodyTextField.text = @"What's Hoppin'...?";
    _messageBodyTextField.textColor = [UIColor lightGrayColor]; //optional
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //make sure we hide the keyboard before dismissing
    [self.view endEditing:YES];
}

#pragma mark - Bar Button Interaction Methods
//if here, we want to tell the news feed to post a comment on the user's behalf
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    
    [[NewsFeed currentFeed] postMessageWithMessageBody:_messageBodyTextField.text];
    
}

//if here, we need to dismiss ourselves
- (IBAction)cancelButtonPushed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextView Delegate Methods
//so we can cap characters
//and also hide the keyboard on done
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([text isEqualToString:@"What's Hoppin'...?"]) {
        [self.tableView headerViewForSection:1].textLabel.text = @"Message (0/140)";
    } else {
        [self.tableView headerViewForSection:1].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:1];
        
    }
    
    
    return textView.text.length + (text.length - range.length) <= 140;
    
}


-(void) textViewShouldBeginEditing {
  
}

//so we can have our placeholder text
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"What's Hoppin'...?"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"What's Hoppin'...?";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegat Methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Location and Time";
            break;
        case 1:
            if ([_messageBodyTextField.text isEqualToString:@"What's Hoppin'...?"]) {
              sectionName = [NSString stringWithFormat:@"MESSAGE (0/140)"];
            } else {
                sectionName = [NSString stringWithFormat:@"MESSAGE (%lu/140)", (unsigned long)_messageBodyTextField.text.length+1];
            }
           
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


#pragma mark - Notification Methods
-(void) didSendMessage: (NSNotification *) notification {
    [self dismissViewControllerAnimated:YES completion:nil];
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


@end

//
//  LiveFeedTableViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/17/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "LiveFeedTableViewController.h"
#import "NewsFeed.h"
#import "MessageTableViewCell.h"
#import "UserDetails.h"

@interface LiveFeedTableViewController ()

//we keep track of our UITextViews as we create them, so we can get their heights
//although all we really need is their attributed strings
@property (strong, nonatomic) NSMutableDictionary *textViews;

//for showing points
@property (strong, nonatomic) IBOutlet UIBarButtonItem *hoppPoints;

@property int segValue;

@end

@implementation LiveFeedTableViewController

#pragma mark - View Controller Life Cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init seg control
    _segValue = 1;
    
    //register for the notifications we will receive from the News Feed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateMessages:)
                                                 name:@"NewsFeedDidUpdateMessages"
                                               object:nil];
    
    //set up pull to refresh
    [self setUpPullToRefresh];
    
    
    //initialize our text view dictionary
    _textViews = [[NSMutableDictionary alloc] init];
    
}


//style our nav and tab bar
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //style the nav bar
    [self styleNavigationController];
    
    //and start spinning
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
    //get news feed messages
    [[NewsFeed currentFeed] getMessagesWithSort:_segValue];
    

    
    //we would like our table to have a gray background
    [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
}


- (void)doit {
    [self.tableView reloadData];
}


//more things to do here
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self performSelector:@selector(doit) withObject:nil afterDelay:1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Methods

//when we receive this message, the News Feed has gotten new messages, so we want to update our table
- (void) didUpdateMessages: (NSNotification *) notification {
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
    //set the points
//    _hoppPoints.title = [[UserDetails currentUser] points];
    
}

#pragma mark - Table View Delegate and Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //we have one section for each message
    return [[NewsFeed currentFeed] messages].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //we have one row for each section
    return 1;
}

//we want to have the cells have dynamic height based on how much text they have in the message
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITextView *temp = [_textViews objectForKey:indexPath];
    
    //if we have some text, then let's get it and ask our method to tell us how much v space that will take up and then add room for our controls
    if (temp.text != nil) {
        CGFloat num = [self textViewHeightForAttributedText:temp.attributedText andWidth:self.tableView.frame.size.width-40];

        //arbitrary number but seems to work
        return num+43;
    }

    //if no text, show nothing
    else {
        return 0;
    }

}

//thanks, stack overflow for this
//calculates height of textview
- (CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    [calculationView sizeToFit];
    [calculationView layoutIfNeeded];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}


//TODO: Matt, we want to style these messages like the designer had mocked-up in her most recent PDFs.
//Some notes that may be helpful:
    //The data source of this TVC is the "NewsFeed" singleton. When this class calls [[NewsFeed currentFeed] getMessages] it tells the NewsFeed to send an asynch request to our server and retrieve the newest JSON. When that's back, it sends a notification that is caught here in the didUpdateMessages method which calls [self.tableView reloadData].
    //The news feed contains an NSArray, called messages, that is a list of NSDictionary's (one dictionary for each comment). The keys for the dictionary are "messageID", "location", "messageBody", "time", and "voteCount." They return strings that do what you might expect. To get the voteCount, you may need to call the intValue NSString class method.
    //In the storyboard for this class, I have the reuseable cell with the identifier "TestMessageCell", which is referenced below. I've created a subclass of UITableView called MessageTableViewCell, which takes care of making itself narrow, and controls the UITextView for the message and the other controls. If you would rather use a different approach to make the custom cells, that's totally fine with me.
    //Please let me know if you have other questions!

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //dequeue our cell
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestMessageCell" forIndexPath:indexPath];
    
    //set the message
    cell.messageBody.text = [[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"messageBody"];
    
    //set the time
    cell.time.text = [[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"time"];
    
    //set the location
    cell.location.text = [[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"location"];
    
    //set the voute count
    cell.pointLabel.text = [[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"voteCount"];
    
    //and give it the ID
    cell.messageID = [[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"messageID"];
    
    if ([[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"locationHotness"] == nil){
        [cell.heatImageView setImage:[UIImage imageNamed:@"blueHotness"]];
        [cell.markerImageView setImage:[UIImage imageNamed:@"blueMarker"]];
        [cell.location setTextColor:[UIColor grayColor]];
    } else if ([[[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"locationHotness"] intValue] == -1){
        [cell.heatImageView setImage:nil];
        [cell.markerImageView setImage:[UIImage imageNamed:@"marker"]];
        [cell.location setTextColor:[UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/240.0 alpha:1.0]];
    } else if ([[[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"locationHotness"] intValue] == 0){
        [cell.heatImageView setImage:[UIImage imageNamed:@"blueHotness"]];
        [cell.markerImageView setImage:[UIImage imageNamed:@"blueMarker"]];
        [cell.location setTextColor:[UIColor colorWithRed:9.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1.0]];
    } else if ([[[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"locationHotness"] intValue] == 1){
        [cell.heatImageView setImage:[UIImage imageNamed:@"yellowHotness"]];
        [cell.markerImageView setImage:[UIImage imageNamed:@"yellowMarker"]];
        [cell.location setTextColor:[UIColor colorWithRed:252.0/255.0 green:176.0/255.0 blue:60.0/255.0 alpha:1]];
    } else if ([[[[[NewsFeed currentFeed] messages] objectAtIndex:indexPath.section] objectForKey:@"locationHotness"] intValue] == 2){
        [cell.heatImageView setImage:[UIImage imageNamed:@"orangeHotness"]];
        [cell.markerImageView setImage:[UIImage imageNamed:@"orangeMarker"]];
        [cell.location setTextColor:[UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:40.0/255.0 alpha:1]];
    } else {
        [cell.heatImageView setImage:[UIImage imageNamed:@"redHotness"]];
        [cell.markerImageView setImage:[UIImage imageNamed:@"redMarker"]];
        [cell.location setTextColor:[UIColor colorWithRed:223.0/255.0 green:60.0/255.0 blue:38.0/255.0 alpha:1]];
    }
    
    //[cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
   // [cell.contentView.layer setBorderWidth:.250f];
    
    //TODO: Matt look here too! This returns nil if the user hasn't voted on the message (by ID) yet and the vote if they have.
    NSString *hasVoted = [[[UserDetails currentUser] voteHistory] objectForKey:cell.messageID];
    [cell awakeFromNib];
    
    if ([hasVoted isEqual:@"upVote"]){
        [cell.upvoteButton setBackgroundImage:[UIImage imageNamed:@"redThumbsUp.png"] forState:UIControlStateNormal];
    } else if ([hasVoted isEqual:@"downVote"]){
        [cell.downvoteButton setBackgroundImage:[UIImage imageNamed:@"redThumbsDown.png"] forState:UIControlStateNormal];
    }
    
    //check if the user has already voted on this message
    if (hasVoted != nil) {
        cell.hasVoted = YES;
    } else {
        cell.hasVoted = NO;
    }
    
    [_textViews setObject:cell.messageBody forKey:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 4.0;
    }
    
    return 2.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 2.0;
}


#pragma mark - Sorting Methods
- (IBAction)hasSortedMessages:(id)sender {
    
    //get our control and the selected value
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    //this is new
    if (selectedSegment == 0) {
        _segValue = 0;
        [[NewsFeed currentFeed] sortMessagesByNewness];
    }
    
    else{
        _segValue = 1;
        [[NewsFeed currentFeed] sortMessagesByHotness];
    }
    
}


#pragma mark - Add New Comment Methods
//when here, the user has tapped the compose button
- (IBAction)composeButtonPressed:(UIBarButtonItem *)sender {
    
    //we just want to segue to the add comment section
    [self performSegueWithIdentifier:@"AddCommentSegue" sender:nil];
    
}

#pragma mark - Pull To Refresh Methods
-(void) setUpPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor colorWithRed:.85 green:.1 blue:0 alpha:1]];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    //ask for new messages
    [[NewsFeed currentFeed] getMessagesWithSort:_segValue];
    
    //start the spinner
    [self.refreshControl beginRefreshing];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

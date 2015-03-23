//
//  PartyDetailsTableViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "PartyDetailsTableViewController.h"
#import "PartyDetails.h"
#import "MessageTableViewCell.h"
#import "UserDetails.h"

@interface PartyDetailsTableViewController ()

//we keep track of our UITextViews as we create them, so we can get their heights
//although all we really need is their attributed strings
@property (strong, nonatomic) NSMutableDictionary *textViews;

@property BOOL showCell;

@end

@implementation PartyDetailsTableViewController

#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showCell = YES;
    
    //register for the notifications we will receive from Party Details
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadData:)
                                                 name:@"PartyDetailsDidLoadData"
                                               object:nil];
    
    //initialize our textView dictionary
    _textViews = [[NSMutableDictionary alloc] init];
    
    //set up pull to refresh
    [self setUpPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //tell the party to load
    [[PartyDetails currentParty] setCurrentPartyToPartyWithName:_seguePartyName];
    
    //and start the spinner
    [self.refreshControl beginRefreshing];
    
    //set our title
    self.navigationItem.title = _seguePartyName;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Notification Methods
- (void) didLoadData: (NSNotification *) notification {
    
    _showCell = YES;
    
    //update data
    [self.tableView reloadData];
    
    //and stop the spinner
    [self.refreshControl endRefreshing];
}

#pragma mark - Pull To Refresh Methods
-(void) setUpPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor colorWithRed:.85 green:.1 blue:0 alpha:1]];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    
    //ask for new messages
    [[PartyDetails currentParty] updatePartyData];
    
    //start the spinner
    [self.refreshControl beginRefreshing];
    
     NSLog(@"%@", [[PartyDetails currentParty] partyMessages]);
    
}

#pragma mark - Table view data source

//we have 2 sections: demographics and messsages
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

//we have 1 for demographics (for now), and count of PartyDetails message's array
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [[PartyDetails currentParty] partyMessages].count*2-1;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if we're doing the demographics
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsTestCell" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"%d",[[PartyDetails currentParty] numPeople]];
         return cell;
    }
    
    //we're showing messages
    else {
        
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestMessageCell" forIndexPath:indexPath];
        
        //we want to display the real cell
        if (_showCell && indexPath.row % 2 == 0) {
            
            //set the message
            cell.messageBody.text = [[[[PartyDetails currentParty] partyMessages] objectAtIndex:indexPath.row/2] objectForKey:@"messageBody"];
            
            //set the time
            cell.time.text = [[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"time"];
            
            //set the location
            cell.location.text = [[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"location"];
            
            //set the voute count
            cell.pointLabel.text = [[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"voteCount"];
            
            //and give it the ID
            cell.messageID = [[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"messageID"];
            
            //[cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            // [cell.contentView.layer setBorderWidth:.250f];
            
            NSString *hasVoted = [[[UserDetails currentUser] voteHistory] objectForKey:cell.messageID];
            
            if (hasVoted != nil) {
                cell.hasVoted = YES;
            } else {
                cell.hasVoted = NO;
            }
            
            [_textViews setObject:cell.messageBody forKey:indexPath];
            
        _showCell = NO;
    }
    
        //we want to be blank
        else {
            
            NSLog(@"yolo");
            cell.messageBody.text = @"BLANK CELL";
            [_textViews setObject:cell.messageBody forKey:indexPath];
            
            cell.userInteractionEnabled = NO;
            cell.hidden = YES;
            
            _showCell = YES;
            
        }
        
        return cell;
    }
    
}

//we want to have the cells have dynamic height based on how much text they have in the message
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if we're doing demographcs
    if (indexPath.section == 0) {
        return 44;
    }
    
    //else, we're doing messages
    else {
    
    //get our text view
    UITextView *temp = [_textViews objectForKey:indexPath];
    
    //if we have some text, then let's get it and ask our method to tell us how much v space that will take up and then add room for our controls
    if (temp.text != nil && ![temp.text isEqualToString:@"BLANK CELL"]) {
        CGFloat num = [self textViewHeightForAttributedText:temp.attributedText andWidth:self.tableView.frame.size.width-40];
        
        //arbitrary number but seems to work
        return num+43;
    } else if ([temp.text isEqualToString:@"BLANK CELL"]) {
        return 15;
    }
    
    //if no text, we are the divider in between rows, so some arbitrary number
    else {
        return 0;
    }
        
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"DEMOGRAPHICS";
            break;
        case 1:
            sectionName = [NSString stringWithFormat:@"MESSAGES FROM %@", [[PartyDetails currentParty] partyName]];
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
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

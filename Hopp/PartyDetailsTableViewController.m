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
#import "DetailsTableViewCell.h"
#import "UserDetails.h"
#import "NewsFeed.h"

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
    
    self.tableView.contentInset = UIEdgeInsetsMake(-36.0f, 0.0f, 0.0f, 0.0f);
    
    //register for the notifications we will receive from Party Details
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadData:)
                                                 name:@"PartyDetailsDidLoadData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateMessages:)
                                                 name:@"NewsFeedDidUpdateMessages"
                                               object:nil];
    
    //initialize our textView dictionary
    _textViews = [[NSMutableDictionary alloc] init];
    
    //set up pull to refresh
    [self setUpPullToRefresh];
    
    // NSLog(@"%@", self.seguePartyDetails);
    self.tableView.tableHeaderView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //tell the party to load
    [[PartyDetails currentParty] setCurrentPartyToPartyWithName:_seguePartyName];
    
    //and start the spinner
    [self.refreshControl beginRefreshing];
    
    //set our title
    self.navigationItem.title = @"PARTY DETAILS";
    
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

//when we receive this message, the News Feed has gotten new messages, so we want to update our table
- (void) didUpdateMessages: (NSNotification *) notification {
    
    [self.tableView reloadData];
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
    
    //  NSLog(@"%@", [[PartyDetails currentParty] partyMessages]);
    
}

#pragma mark - Table view data source
//we have 1 for demographics (for now), and count of PartyDetails message's array
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if we're doing the demographics
    if (indexPath.section == 0) {
        DetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestDetailsCell" forIndexPath:indexPath];
        
        int percent = [[self.seguePartyDetails objectForKey:@"Percent Girls"] intValue]/5;
        NSString *femString = @"";
        NSString *malString = @"";
        
        for (int i = 1; i <= percent; i++)
        {
            femString = [femString stringByAppendingString:@"ll"];
        }
        
        int count = [femString length];
        int otherCount = 40 - count;
        
        for (int i = 1; i <= otherCount; i++)
        {
            malString = [malString stringByAppendingString:@"l"];
        }
        
        [cell.malesLabel setTextColor:[UIColor colorWithRed:37.0/255.0 green:170.0/255.0 blue:224.0/255.0 alpha:1]];
        [cell.femalesLabel setTextColor:[UIColor colorWithRed:237.0/255.0 green:36.0/255.0 blue:123.0/255.0 alpha:1]];
        
        [cell.malesMeterLabel setText:malString];
        [cell.malesMeterLabel setTextColor:[UIColor colorWithRed:37.0/255.0 green:170.0/255.0 blue:224.0/255.0 alpha:1]];
        [cell.malesMeterLabel setBackgroundColor:[UIColor colorWithRed:37.0/255.0 green:170.0/255.0 blue:224.0/255.0 alpha:1]];
        [cell.malesMeterLabel sizeToFit];
        
        [cell.femalesMeterLabel setText:femString];
        [cell.femalesMeterLabel setTextColor:[UIColor colorWithRed:237.0/255.0 green:36.0/255.0 blue:123.0/255.0 alpha:1]];
        [cell.femalesMeterLabel setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:36.0/255.0 blue:123.0/255.0 alpha:1]];
        [cell.femalesMeterLabel sizeToFit];
        
        if ([[self.seguePartyDetails objectForKey:@"Dress Code"] isEqual: @"theme"]){
            [cell.dressTypeImageView setImage:[UIImage imageNamed:@"theme.png"]];
            [cell.dressTypeLabel setText:@"Theme"];
        } else if ([[self.seguePartyDetails objectForKey:@"Dress Code"] isEqual: @"formal"]) {
            [cell.dressTypeImageView setImage:[UIImage imageNamed:@"formal.png"]];
            [cell.dressTypeLabel setText:@"Formal"];
        } else { // casual
            [cell.dressTypeImageView setImage:[UIImage imageNamed:@"casual.png"]];
            [cell.dressTypeLabel setText:@"Casual"];
        }
        
        // NSLog(@"%@", [[self.seguePartyDetails objectForKey:@"Party Types"] objectAtIndex:0]);
        
        // NSLog(@"sup");
        // NSLog(@"%@", NSStringFromClass([[self.seguePartyDetails objectForKey:@"Party Types"] class]));
        if (!([[self.seguePartyDetails objectForKey:@"Party Types"] isKindOfClass:[NSArray class]])){
            // NSLog(@"yolo;");
        }
        else if ([[self.seguePartyDetails objectForKey:@"Party Types"] count] == 0){
            [cell.partyTypeImageView setImage:[UIImage imageNamed:@"pregame.png"]];
            [cell.partyTypeLabel setText:@"Pregame"];
        } else if ([[[self.seguePartyDetails objectForKey:@"Party Types"] objectAtIndex:0] isEqual: @"pregame"]){
            [cell.partyTypeImageView setImage:[UIImage imageNamed:@"pregame.png"]];
            [cell.partyTypeLabel setText:@"Pregame"];
        } else if ([[[self.seguePartyDetails objectForKey:@"Party Types"] objectAtIndex:0] isEqual: @"dorm"]) {
            [cell.partyTypeImageView setImage:[UIImage imageNamed:@"dorm.png"]];
            [cell.partyTypeLabel setText:@"Dorm Party"];
        } else if ([[[self.seguePartyDetails objectForKey:@"Party Types"] objectAtIndex:0] isEqual: @"dance"]) {
            [cell.partyTypeImageView setImage:[UIImage imageNamed:@"dance.png"]];
            [cell.partyTypeLabel setText:@"Dance Party"];
        } else { // after
            [cell.partyTypeImageView setImage:[UIImage imageNamed:@"afterparty.png"]];
            [cell.partyTypeLabel setText:@"After Party"];
        }
        
        // NSLog(@"%@", [self.seguePartyDetails objectForKey:@"Drink List"]);
        if (!([[self.seguePartyDetails objectForKey:@"Drink List"] isKindOfClass:[NSArray class]])){
            // NSLog(@"yolo;");
        }
        else if ([[self.seguePartyDetails objectForKey:@"Drink List"] count] == 0){
            [cell.noAlcoholImageView setImage:[UIImage imageNamed:@"none_highlighted.png"]];
            [cell.noAlcoholLabel setTextColor:[UIColor colorWithRed:9.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1]];
            [cell.noAlcoholLabel2 setTextColor:[UIColor colorWithRed:9.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1]];
        }
        else {
            for (NSString *s in [self.seguePartyDetails objectForKey:@"Drink List"]) {
                if ([s isEqual:@"beer"]){
                    [cell.beerImageView setImage:[UIImage imageNamed:@"beer_highlighted.png"]];
                    [cell.beerLabel setTextColor:[UIColor colorWithRed:252.0/255.0 green:176.0/255.0 blue:60.0/255.0 alpha:1]];
                } else if ([s isEqual:@"wine"]){
                    [cell.wineImageView setImage:[UIImage imageNamed:@"wine_highlighted.png"]];
                    [cell.wineLabel setTextColor:[UIColor colorWithRed:223.0/255.0 green:60.0/255.0 blue:38.0/255.0 alpha:1]];
                } else if ([s isEqual:@"hard"]){
                    [cell.liquorImageView setImage:[UIImage imageNamed:@"liquor_highlighted.png"]];
                    [cell.liquorLabel setTextColor:[UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:40.0/255.0 alpha:1]];
                    [cell.liquorLabel2 setTextColor:[UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:40.0/255.0 alpha:1]];
                } else if ([s isEqual:@"none"]){
                    [cell.noAlcoholImageView setImage:[UIImage imageNamed:@"none_highlighted.png"]];
                    [cell.noAlcoholLabel setTextColor:[UIColor colorWithRed:9.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1]];
                    [cell.noAlcoholLabel2 setTextColor:[UIColor colorWithRed:9.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1]];
                }
            }
        }
        
        if ([[self.seguePartyDetails objectForKey:@"Hopp Level"] intValue] == 0){
            [cell.hotnessImageView setImage:[UIImage imageNamed:@"blueHotness.png"]];
        } else if ([[self.seguePartyDetails objectForKey:@"Hopp Level"] intValue] == 1){
            [cell.hotnessImageView setImage:[UIImage imageNamed:@"yellowHotness.png"]];
        } else if ([[self.seguePartyDetails objectForKey:@"Hopp Level"] intValue] == 2){
            [cell.hotnessImageView setImage:[UIImage imageNamed:@"orangeHotness.png"]];
        } else { // 3
            [cell.hotnessImageView setImage:[UIImage imageNamed:@"redHotness.png"]];
        }
        
        [cell.locationLabel setText:[self.seguePartyDetails objectForKey:@"Name"]];
        
        
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
            
            //set the vote count
            cell.pointLabel.text = [[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"voteCount"];
            
            //and give it the ID
            cell.messageID = [[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"messageID"];
            
            //[cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            // [cell.contentView.layer setBorderWidth:.250f];
            
//            NSLog(@"%@", [[PartyDetails currentParty] partyMessages]);
            
            if ([[[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"Hopp Level"] intValue] == 0){
                [cell.heatImageView setImage:[UIImage imageNamed:@"blueHotness"]];
                [cell.markerImageView setImage:[UIImage imageNamed:@"blueMarker"]];
                [cell.location setTextColor:[UIColor colorWithRed:9.0/255.0 green:115.0/255.0 blue:186.0/255.0 alpha:1.0]];
            } else if ([[[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"Hopp Level"]  intValue] == 1){
                [cell.heatImageView setImage:[UIImage imageNamed:@"yellowHotness"]];
                [cell.markerImageView setImage:[UIImage imageNamed:@"yellowMarker"]];
                [cell.location setTextColor:[UIColor colorWithRed:252.0/255.0 green:176.0/255.0 blue:60.0/255.0 alpha:1]];
            } else if ([[[[[PartyDetails currentParty] partyMessages]  objectAtIndex:indexPath.row/2] objectForKey:@"Hopp Level"] intValue] == 2){
                [cell.heatImageView setImage:[UIImage imageNamed:@"orangeHotness"]];
                [cell.markerImageView setImage:[UIImage imageNamed:@"orangeMarker"]];
                [cell.location setTextColor:[UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:40.0/255.0 alpha:1]];
            } else {
                [cell.heatImageView setImage:[UIImage imageNamed:@"redHotness"]];
                [cell.markerImageView setImage:[UIImage imageNamed:@"redMarker"]];
                [cell.location setTextColor:[UIColor colorWithRed:223.0/255.0 green:60.0/255.0 blue:38.0/255.0 alpha:1]];
            }
            
            NSString *hasVoted = [[[UserDetails currentUser] voteHistory] objectForKey:cell.messageID];
            
            [cell awakeFromNib];
            
            if ([hasVoted isEqual:@"upVote"]){
                [cell.upvoteButton setBackgroundImage:[UIImage imageNamed:@"redThumbsUp.png"] forState:UIControlStateNormal];
            } else if ([hasVoted isEqual:@"downVote"]){
                [cell.downvoteButton setBackgroundImage:[UIImage imageNamed:@"redThumbsDown.png"] forState:UIControlStateNormal];
            }
            
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
            cell.messageBody.text = @"BLANK CELL";
            [_textViews setObject:cell.messageBody forKey:indexPath];
            
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
        return 590;
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *sectionName;
//    switch (section)
//    {
//        case 0:
//            sectionName = nil;
//            break;
//        case 1:
//            sectionName = [NSString stringWithFormat:@"MESSAGES FROM %@", [[PartyDetails currentParty] partyName]];
//            break;
//        default:
//            sectionName = @"";
//            break;
//    }
//    return sectionName;
//}

//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView;
//    if (section == 0){
//        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
//    } else {
//        UILabel *objLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,40)];
//        objLabel.text = @"Post";
//        objLabel.textColor = [UIColor blackColor];
//        [headerView addSubview:objLabel];
//    }
//    return headerView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
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

//
//  PartyDetailsTableViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "PartyDetailsTableViewController.h"
#import "PartyDetails.h"

@interface PartyDetailsTableViewController ()

@end

@implementation PartyDetailsTableViewController

#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //register for the notifications we will receive from Party Details
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadData:)
                                                 name:@"PartyDetailsDidLoadData"
                                               object:nil];
    
    //set up pull to refresh
    [self setUpPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //tell the party to load
    [[PartyDetails currentParty] setCurrentPartyToPartyWithName:_seguePartyName];
    
    //and start the spinner
    [self.refreshControl beginRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Methods
- (void) didLoadData: (NSNotification *) notification {
    
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
    
}

#pragma mark - Table view data source

//we have 3 sections: name, demographics, and messsages
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

//we have 1 for name, 1 for people, and count of PartyDetails message's array
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return [[PartyDetails currentParty] partyMessages].count;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsTestCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        //set this to party name
        cell.textLabel.text = [[PartyDetails currentParty] partyName];
    }
    
    else if (indexPath.section == 1) {
        //set this to party num people
        cell.textLabel.text = [NSString stringWithFormat:@"%d",[[PartyDetails currentParty] numPeople]];
    }
    
    else {
        cell.textLabel.text = [[[[PartyDetails currentParty] partyMessages] objectAtIndex:indexPath.row] objectForKey:@"messageBody"];
    }
    
    return cell;
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

//
//  PartyListViewTableViewController.m
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "PartyListViewTableViewController.h"
#import "PartyDetailsTableViewController.h"
#import "PartyListTableViewCell.h"
#import "UserDetails.h"

@interface PartyListViewTableViewController () <NSURLConnectionDelegate>

//for asynch requests
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSArray *partyList;

@end

@implementation PartyListViewTableViewController


#pragma mark - Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //style our nav bar
    [self styleNavigationController];
    
    //set up pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshList)
                  forControlEvents:UIControlEventValueChanged];
    
    //initialize array
    _partyList = [[NSArray alloc] init];

    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //start spinning
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
    //get news feed messages
    [self refreshList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Pull To Refresh Methods
- (void) refreshList {
    
    //here, we want to send off an asynch request to reload the data
    NSString *urlEncoded = @"http://lanemiles.com/Hopp/getPartyLocationData.php";
    
    // Create the request for the data
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEncoded]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _partyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PartyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PartyListTableViewCell" forIndexPath:indexPath];
    
    [cell.locationLabel setText:[_partyList[indexPath.row] objectForKey: @"Name"]];
    [cell.locationLabel setFont:[UIFont fontWithName:@"SourceSansPro-Bold" size:14]];
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:[[[UserDetails currentUser] latitude] floatValue] longitude:[[[UserDetails currentUser] longitude] floatValue]];
    CLLocation *partyLocation = [[CLLocation alloc] initWithLatitude:[[_partyList[indexPath.row] objectForKey: @"Latitude"] floatValue] longitude:[[_partyList[indexPath.row] objectForKey: @"Longitude"] floatValue]];
    CLLocationDistance meters = [partyLocation distanceFromLocation:currentLocation];

    [cell.distanceLabel setText:[NSString stringWithFormat:@"%.2f miles", (meters/ 1600)]];
    [cell.distanceLabel setFont:[UIFont fontWithName:@"SourceSansPro-Regular" size:14]];
    
    if ([[_partyList[indexPath.row] objectForKey: @"Hopp Level"] isEqual:@""]) {
        [cell.hotnessImageView setImage:[UIImage imageNamed:@"blueHotnessCircle"]];
    } else if ([[_partyList[indexPath.row] objectForKey: @"Hopp Level"] intValue] == 0) {
        [cell.hotnessImageView setImage:[UIImage imageNamed:@"blueHotnessCircle"]];
    }
    else if ([[_partyList[indexPath.row] objectForKey: @"Hopp Level"] intValue] == -1) {
        [cell.hotnessImageView setImage:[UIImage imageNamed:@"blueHotnessCircle"]];
    }
    
    else if ([[_partyList[indexPath.row] objectForKey: @"Hopp Level"] intValue] == 1) {
        [cell.hotnessImageView setImage:[UIImage imageNamed:@"yellowHotnessCircle"]];
    } else if ([[_partyList[indexPath.row] objectForKey: @"Hopp Level"] intValue] == 2) {
        [cell.hotnessImageView setImage:[UIImage imageNamed:@"orangeHotnessCircle"]];
    } else {
        [cell.hotnessImageView setImage:[UIImage imageNamed:@"redHotnessCircle"]];
    }

    return cell;
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

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 1.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

//we want to have the cells have dynamic height based on how much text they have in the message
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
    
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
   //if we get here, we've gotten new data, so let's refresh our table
    NSError* error;
    NSArray* json = [[NSJSONSerialization JSONObjectWithData:_responseData
                                                          options:kNilOptions
                                                            error:&error] objectForKey:@"Data"];
    if (error) {
        // NSLog(@"%@", error);
    } else {
        
        //if we don't have an error in reading the JSON, let's set our instance variables
        _partyList = json;
        
        //now reload table
        [self.tableView reloadData];
        
        //and then stop spinning
        [self.refreshControl endRefreshing];
        
    }

    
}





- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    // NSLog(@"%@", error);
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //check if seguing to a party detail TVC
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {

        UINavigationController *navController = [segue destinationViewController];
        PartyDetailsTableViewController *new = (PartyDetailsTableViewController *)([navController viewControllers][0]);

        PartyListTableViewCell *senderCell = (PartyListTableViewCell *)sender;

        new.seguePartyName = senderCell.locationLabel.text;
        
        // pass details of the party
        for (NSDictionary *dict in _partyList) {
            if ([[dict valueForKey:@"Name"] isEqual:senderCell.locationLabel.text]){
                new.seguePartyDetails = dict;
            }
        }
        
    } else {
      
        PartyDetailsTableViewController *new = (PartyDetailsTableViewController *)segue.destinationViewController;
        
        PartyListTableViewCell *senderCell = (PartyListTableViewCell *)sender;
  
        new.seguePartyName = senderCell.locationLabel.text;
        
        // pass details of the party
        for (NSDictionary *dict in _partyList) {
            if ([[dict valueForKey:@"Name"] isEqual:senderCell.locationLabel.text]){
                new.seguePartyDetails = dict;
            }
        }
    }
    
}




@end

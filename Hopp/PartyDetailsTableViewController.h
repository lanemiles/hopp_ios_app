//
//  PartyDetailsTableViewController.h
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartyDetailsTableViewController : UITableViewController

//this is set by the segue
@property (strong,nonatomic) NSString *seguePartyName;
@property (strong,nonatomic) NSDictionary *seguePartyDetails;

@end

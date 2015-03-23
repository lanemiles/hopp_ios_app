//
//  MessageTableViewCell.h
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

//labels set from the table view class
@property (strong, nonatomic) IBOutlet UITextView *messageBody;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UILabel *pointLabel;
@property (strong, nonatomic) IBOutlet UIButton *upvoteButton;
@property (strong, nonatomic) IBOutlet UIButton *downvoteButton;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *markerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *heatImageView;
@property (strong, nonatomic) NSString *messageID;

//booleans to only allow voting once
@property BOOL hasVoted;

@end

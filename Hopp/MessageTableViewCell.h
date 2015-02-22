//
//  MessageTableViewCell.h
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextView *messageBody;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;

@end

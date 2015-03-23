//
//  PartyListTableViewCell.h
//  Hopp
//
//  Created by Matthew Sloane on 3/22/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartyListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *triangleButton;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *hotnessImageView;

@end

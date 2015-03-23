//
//  MessageTableViewCell.m
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "NewsFeed.h"

@implementation MessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.upvoteButton setBackgroundImage:[UIImage imageNamed:@"thumbsUp.png"] forState:UIControlStateNormal];
    [self.downvoteButton setBackgroundImage:[UIImage imageNamed:@"thumbsDown.png"] forState:UIControlStateNormal];
}

-(void) setFrame:(CGRect) frame {
    // frame.origin.x += 10;
    // frame.size.width = self.superview.frame.size.width - (2.0f * 10);
    [super setFrame: frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Voting Methods
- (IBAction)upVotePressed:(UIButton *)sender {
    
    if (!_hasVoted) {
        _hasVoted = YES;
        
        //TODO: Matt this is one of the API methods
        [[NewsFeed currentFeed] upvoteMessageWithID:_messageID];
    }
    
}

- (IBAction)downVotePressed:(UIButton *)sender {
    
    if (!_hasVoted) {
        _hasVoted = YES;
        
        //TODO: Matt this is one of the API methods
        [[NewsFeed currentFeed] downvoteMessageWithID:_messageID];
    }
    
}

@end

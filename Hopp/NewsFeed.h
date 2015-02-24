//
//  NewsFeed.h
//  Hopp
//
//  Created by Lane Miles on 2/17/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFeed : NSObject

//public array of messages
@property (strong, nonatomic) NSArray *messages;

//network methods
- (void) getMessages;
- (void) postMessageWithMessageBody: (NSString *)body;
- (void) upvoteMessageWithID: (NSString *)messageID;
- (void) downvoteMessageWithID: (NSString *)messageID;

//static getter
+ (NewsFeed *)currentFeed;

//sorting methods
- (void) sortMessagesByNewness;
- (void) sortMessagesByHotness;

@end

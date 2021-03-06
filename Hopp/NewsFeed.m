//
//  NewsFeed.m
//  Hopp
//
//  Created by Lane Miles on 2/17/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//
//

#import "NewsFeed.h"
#import "UserDetails.h"

@interface NewsFeed () <NSURLConnectionDelegate>


//this is what we use to store the results of our asynch url request
@property (strong, nonatomic) NSMutableData *responseData;



@end

@implementation NewsFeed

// BOOL hotness = TRUE;

#pragma mark - Static Getter
static NewsFeed *currentFeed = nil;

+ (NewsFeed *)currentFeed {
    if (currentFeed == nil) {
        currentFeed = [[self alloc] init];
    }
    return currentFeed;
}


#pragma mark - Sorting Methods
- (void) sortMessagesByHotness {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"voteCount"  ascending:NO];
    _messages = [_messages sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    _sortByHotness = YES;
    [self notifyThatMessagesHaveLoaded];
    
}

- (void) sortMessagesByNewness {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"messageID"  ascending:NO];
    _messages = [_messages sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    _sortByHotness = NO;
    [self notifyThatMessagesHaveLoaded];
    
}

#pragma mark - Network Methods
//get user details from server
- (void) getMessagesWithSort: (int) sort {
    
    if (sort == 1) {
        _sortByHotness = YES;
    } else {
        _sortByHotness = NO;
    }
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.lanemiles.com/Hopp/getMessages.php"]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void) postMessageWithMessageBody: (NSString *)body {
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/addMessage.php?userID=%@&messageID=%f&messageBody=%@", [[UserDetails currentUser] userID], CFAbsoluteTimeGetCurrent(), body]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void) downvoteMessageWithID: (NSString *)messageID {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/downvoteMessage.php?userID=%@&messageID=%@", [[UserDetails currentUser] userID], messageID]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    // NSLog(@"%@", request.URL.absoluteString);
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void) upvoteMessageWithID: (NSString *)messageID {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/upvoteMessage.php?userID=%@&messageID=%@", [[UserDetails currentUser] userID], messageID]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    // NSLog(@"%@", request.URL.absoluteString);
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

#pragma mark - Notification Methods

//after we get our new message data, let's let the LiveFeed TVC know
- (void) notifyThatMessagesHaveLoaded {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsFeedDidUpdateMessages"
                                                        object:nil userInfo:nil];
    
}

//after we post a message
- (void) notifyThatMessageDidSend {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsFeedDidSendMessage"
                                                        object:nil userInfo:nil];
    
}

- (void) notifyThatVoteWasCounted {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewsFeedDidCountMessage"
                                                        object:nil userInfo:nil];
    
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
    //now, let's check to see what request we just successfully completed
    NSString *urlString = connection.currentRequest.URL.absoluteString;
    
    //check if we were getting messages
    if ([urlString rangeOfString:@"getMessages"].location != NSNotFound) {
        
        //we get messages
        NSError* error;
        NSArray* json = [[NSJSONSerialization JSONObjectWithData:_responseData
                                                              options:kNilOptions
                                                                error:&error] objectForKey:@"Data"];
        if (error) {
           //  NSLog(@"%@", error);
        } else {
            
            //if we don't have an error in reading the JSON, let's set our instance variables
            _messages = json;
            
            //default sort by hotness
            //TODO: should this be here?
            if (_sortByHotness){
                [self sortMessagesByHotness];
           } else {
                [self sortMessagesByNewness];
            }
            
            
            //and notify that messages have loaded
            [self notifyThatMessagesHaveLoaded];
            
        }
        
    }
    
    //if not, we must be adding a message, so we should get again after
    else {
        
        //TODO: need this?
        [self notifyThatMessageDidSend];
        
        //update the messages with the new data
        if (_sortByHotness){
            [self getMessagesWithSort:0];
        } else {
            [self getMessagesWithSort:1];
        }
        
        
        //and because we want to reupdate our vote history, we need to get user details again
        [[UserDetails currentUser] getUserDetails];
        
    }
    
}





- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    // NSLog(@"%@", error);
}


@end

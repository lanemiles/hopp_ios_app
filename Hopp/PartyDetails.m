//
//  PartyDetails.m
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "PartyDetails.h"

@interface PartyDetails () <NSURLConnectionDelegate>

//this is what we use to store the results of our asynch url request
@property (strong, nonatomic) NSMutableData *responseData;

@end

@implementation PartyDetails

#pragma mark - Static Getter
static PartyDetails *currentParty = nil;

+ (PartyDetails *) currentParty {
    if (currentParty == nil) {
        currentParty = [[self alloc] init];
    }
    return currentParty;
}

#pragma mark - Network Methods

//set send off our async call
- (void) setCurrentPartyToPartyWithName: (NSString *)name {
   
    //set our name
    _partyName = name;
    
    //encode the space
    NSString *nameEncoded = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlEncoded = [NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/getDataForParty.php?partyName=%@", nameEncoded];
    
    // Create the request for the data
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEncoded]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}


- (void) updatePartyData {
    
    //encode the space
    NSString *nameEncoded = [_partyName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlEncoded = [NSString stringWithFormat:@"http://www.lanemiles.com/Hopp/getDataForParty.php?partyName=%@", nameEncoded];
    
    // Create the request for the data
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEncoded]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

#pragma mark - Notification Methods

//after we get our new message data, let's let the LiveFeed TVC know
- (void) notifyThatPartyDataDidLoad {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PartyDetailsDidLoadData"
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
    
    //check if we were getting data for the party
    if ([urlString rangeOfString:@"getDataForParty"].location != NSNotFound) {
        
        //we get messages
        NSError* error;
        NSArray* json = [[NSJSONSerialization JSONObjectWithData:_responseData
                                                         options:kNilOptions
                                                           error:&error] objectForKey:@"Data"];
        if (error) {
           // NSLog(@"%@", error);
        } else {
            
            //if we don't have an error in reading the JSON, let's set our instance variables
            
            
            //lets get the first element in the array which stores name and num people
            NSDictionary *nameAndNum = [json objectAtIndex:0];
            
            //set it
            _numPeople = [[nameAndNum objectForKey:@"NumPeople"] intValue];
            
            //now lets get the messages
            NSArray *messageList = [json objectAtIndex:1];
            
            //set it
            _partyMessages = messageList;
            
            //and say we're set
            [self notifyThatPartyDataDidLoad];
            
        }
        
    }
    
    //this should never be reached
    else {
        
        
        
    }
    
}





- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    // NSLog(@"%@", error);
}


@end

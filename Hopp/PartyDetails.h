//
//  PartyDetails.h
//  Hopp
//
//  Created by Lane Miles on 2/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartyDetails : NSObject

//party objects
@property int numPeople;
@property (strong, nonatomic) NSArray *partyMessages;
@property (strong, nonatomic) NSString *partyName;

//singleton static getter
+ (id)currentParty;

//network methods
//set send off our async call
- (void) setCurrentPartyToPartyWithName: (NSString *)name;
//set send off our async call
- (void) updatePartyData;


@end

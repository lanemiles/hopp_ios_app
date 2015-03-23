//
//  CustomInfoWindow.m
//  Hopp
//
//  Created by Matthew Sloane on 3/13/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "CustomInfoWindow.h"

@implementation CustomInfoWindow

- (id)initForMarker:(GMSMarker*)marker
{
    self = [super initWithFrame:CGRectMake(0,0, 200, 100)];
    if (self) {
        
        // set background of info window
        UIGraphicsBeginImageContext(self.frame.size);
        [[UIImage imageNamed:@"infowindow.png"] drawInRect:CGRectMake(0, 6.25, 200, 85)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self setBackgroundColor:[UIColor colorWithPatternImage:image]];
        
        // set up hotness image
        if ([marker.userData  isEqual: @"0"]) {
            self.hotnessLevel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueHotnessCircle.png"]];
        } else if ([marker.userData  isEqual: @"1"]) {
            self.hotnessLevel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yellowHotnessCircle.png"]];
        } else if ([marker.userData  isEqual: @"2"]) {
            self.hotnessLevel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orangeHotnessCircle.png"]];
        } else {
            self.hotnessLevel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redHotnessCircle.png"]];
        }
        [self.hotnessLevel setFrame:CGRectMake(0, 0, 100, 100)];
        [self addSubview: self.hotnessLevel];
        
        // set label properties for info window -- eventually need to ensure that text fits in label
        self.titleString = [marker.title uppercaseString];
        self.addressString1 = @"333 N College Way";
        self.addressString2 = @"Claremont, CA 91711";
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 27.5, 80, 40)];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setFont:[UIFont fontWithName:@"SourceSansPro-Bold" size:14]];
        [self.titleLabel setText:[NSString stringWithFormat:@"%@", self.titleString]];
        self.titleLabel.numberOfLines = 0;
        [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self addSubview:self.titleLabel];
        
//        self.addressLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(30, 45, 200, 12)];
//        [self.addressLabel1 setTextAlignment:NSTextAlignmentCenter];
//        [self.addressLabel1 setFont:[UIFont fontWithName:@"SourceSansPro-Regular" size:8]];
//        [self.addressLabel1 setText:[NSString stringWithFormat:@"%@", self.addressString1]];
//        [self addSubview:self.addressLabel1];
//        
//        self.addressLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 54, 200, 12)];
//        [self.addressLabel2 setTextAlignment:NSTextAlignmentCenter];
//        [self.addressLabel2 setFont:[UIFont fontWithName:@"SourceSansPro-Regular" size:8]];
//        [self.addressLabel2 setText:[NSString stringWithFormat:@"%@", self.addressString2]];
//        [self addSubview:self.addressLabel2];
    }
    return self;
}


@end

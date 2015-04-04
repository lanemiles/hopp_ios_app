//
//  CustomInfoWindow.h
//  Hopp
//
//  Created by Matthew Sloane on 3/13/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface CustomInfoWindow : UIView

- (id)initForMarker:(GMSMarker*)marker;

@property NSString *titleString;
//@property NSString *addressString1;
//@property NSString *addressString2;

@property UILabel *titleLabel;
//@property UILabel *addressLabel1;
//@property UILabel *addressLabel2;

@property UIImageView *hotnessLevel;

@end

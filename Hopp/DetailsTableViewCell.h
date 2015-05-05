//
//  DetailsTableViewCell.h
//  Hopp
//
//  Created by Matthew Sloane on 4/22/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *partyTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dressTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *beerLabel;
@property (strong, nonatomic) IBOutlet UILabel *wineLabel;
@property (strong, nonatomic) IBOutlet UILabel *liquorLabel;
@property (strong, nonatomic) IBOutlet UILabel *liquorLabel2;
@property (strong, nonatomic) IBOutlet UILabel *noAlcoholLabel;
@property (strong, nonatomic) IBOutlet UILabel *noAlcoholLabel2;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *malesLabel;
@property (strong, nonatomic) IBOutlet UILabel *femalesLabel;
@property (strong, nonatomic) IBOutlet UILabel *malesMeterLabel;
@property (strong, nonatomic) IBOutlet UILabel *femalesMeterLabel;

@property (strong, nonatomic) IBOutlet UIImageView *partyTypeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dressTypeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *beerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *wineImageView;
@property (strong, nonatomic) IBOutlet UIImageView *liquorImageView;
@property (strong, nonatomic) IBOutlet UIImageView *noAlcoholImageView;

@property (strong, nonatomic) IBOutlet UIImageView *hotnessImageView;

@end

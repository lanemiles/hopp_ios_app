//
//  TermsAndConditionsViewController.m
//  Hopp
//
//  Created by Matthew Sloane on 4/21/15.
//  Copyright (c) 2015 Lane Miles. All rights reserved.
//

#import "TermsAndConditionsViewController.h"

@interface TermsAndConditionsViewController ()

@end

@implementation TermsAndConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ensure that text view text starts at the top
    [self.tacTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    [self.privacyTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    self.tacTextView.layer.borderWidth = 1.0f;
    self.tacTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.privacyTextView.layer.borderWidth = 1.0f;
    self.privacyTextView.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"tac_approved_segue"]){
        
       //  NSLog(@"approved");
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"disclaimerAccepted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([[segue identifier] isEqualToString:@"tac_rejected_segue"]){
             //    NSLog(@"rejected");
        }
                
}




@end

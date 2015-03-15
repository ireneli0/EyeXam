//
//  NewUserInformationViewController.m
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "NewUserInformationViewController.h"
#import "RadioButton.h"
@interface NewUserInformationViewController ()

@end

@implementation NewUserInformationViewController

- (IBAction)onWearGlassesRadioButton:(RadioButton *)sender {
    NSLog(@"wear glasses selected: %@", sender.titleLabel.text);
}

- (IBAction)onEyeTypeRadioButton:(RadioButton *)sender {
    NSLog(@"Eye type selected: %@", sender.titleLabel.text);
}


@end

//
//  NewUserInformationViewController.h
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"


@interface NewUserInformationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet RadioButton *wearGlassesRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *eyeTypeRadioButton;

@property (strong, nonatomic) NSString * wearGlasses;
@property (strong, nonatomic) NSString * eyesightType;
@property (strong, nonatomic) NSString * user;

@end

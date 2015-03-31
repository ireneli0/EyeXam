//
//  ViewController.h
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *btn_startNewGame;
@property (strong, nonatomic) IBOutlet UIButton *btn_checkPreviousResult;
@property (strong, nonatomic) IBOutlet UIButton *btn_viewMyProfile;
@property (strong, nonatomic) IBOutlet UIButton *btn_changeUser;
@property (weak, nonatomic) IBOutlet UILabel *welcomeUserLabel;
@end


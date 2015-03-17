//
//  ViewProfileViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ViewProfileViewController.h"
#import "DatabaseInstance.h"
#import "userInfo.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"View Profile";
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    NSArray * currentUser = [[DatabaseInstance getSharedInstance] getAllInfoForSelectedUser:self.userName];
    userInfo *currentUserInfo = [currentUser objectAtIndex:0];
    
    self.userNameLabel.text = currentUserInfo.userName;
    self.wearGlassesLabel.text = currentUserInfo.wearGlasses;
    self.EyesightTypeLabel.text = currentUserInfo.eyesightType;
}

@end
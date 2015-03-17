//
//  ViewProfileViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ViewProfileViewController.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"View Profile";
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
}

@end

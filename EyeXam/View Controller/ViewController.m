//
//  ViewController.m
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ViewController.h"
#import "AdjustDistanceViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSString *userName;
@end

@implementation ViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"EyeXam";


}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    //NSLog(@"username retrieved = %@", self.userName);
    self.welcomeUserLabel.text =[NSString stringWithFormat:@"Welcome, %@", self.userName];
}


@end

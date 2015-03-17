//
//  ViewController.m
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ViewController.h"
#import "AdjustDistanceViewController.h"
#import "ResultsDisplayViewController.h"
#import "LineChartResultsDisplayViewController.h"

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CheckResults"]) {
        if ([segue.destinationViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabar=segue.destinationViewController;
            ResultsDisplayViewController *rdVC=[tabar.viewControllers objectAtIndex:0];
            rdVC.userName = self.userName;
    
            LineChartResultsDisplayViewController *lcVC = [tabar.viewControllers objectAtIndex:1];
            lcVC.userName = self.userName;
        }
    }
    
}

@end

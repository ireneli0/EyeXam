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
#import "ChangeUserViewController.h"
#import "DatabaseInstance.h"
#import "userInfo.h"

@interface ViewController ()
@property (strong, nonatomic) NSString *userName;
@end

@implementation ViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"EyeXam";
//    int resultRight = 20/1.0;
//    int resultLeft = 20/2.0;
//    
//    float meterValue = 2.0;
//    NSString *testMeters = [NSString stringWithFormat:@"%.1f", meterValue];
//    NSString *lefteyeResult = [NSString stringWithFormat:@"20/%d", resultLeft];
//    NSString *righteyeResult = [NSString stringWithFormat:@"20/%d", resultRight];
//
//    NSString *wearGlasses = @"With glasses";
//    NSString *userName = @"Yi";
//    NSString *currenttime;
//    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
//    currenttime = [formatter stringFromDate:[NSDate date]];
//    
//    if([[DatabaseInstance getSharedInstance]addNewRecords:@"Records" withName:userName withtestMeter:testMeters withGlasses:wearGlasses withlefteyeResult:lefteyeResult withrighteyeResult:righteyeResult withTime:currenttime]){
//        NSLog(@"update Records succeessfully");
//    }

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
    }else if ([segue.identifier isEqualToString:@"ChangeUser"]){
        if ([segue.destinationViewController isKindOfClass:[ChangeUserViewController class]]) {
            ChangeUserViewController *cuVC = (ChangeUserViewController*)segue.destinationViewController;
            cuVC.userName = self.userName;
            cuVC.allUsersArray = [[DatabaseInstance getSharedInstance] getAllUsers];
            NSLog(@"allusers count %lu", (unsigned long)[cuVC.allUsersArray count]);
        }
    }else if ([segue.identifier isEqualToString:@"AdjustDistance"]){
        if ([segue.destinationViewController isKindOfClass:[AdjustDistanceViewController class]]) {
            AdjustDistanceViewController *adVC = (AdjustDistanceViewController*)segue.destinationViewController;
            adVC.userName = self.userName;
        }
    }
    
    
    
    
}

@end

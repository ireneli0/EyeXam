//
//  LineChartResultsDisplayViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "LineChartResultsDisplayViewController.h"

@interface LineChartResultsDisplayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation LineChartResultsDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameLabel.text = self.userName;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

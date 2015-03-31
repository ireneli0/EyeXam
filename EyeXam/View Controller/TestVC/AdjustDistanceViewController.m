//
//  AdjustDistanceViewController.m
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "AdjustDistanceViewController.h"
#import "NewTestViewController.h"


@interface AdjustDistanceViewController()

@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@end

@implementation AdjustDistanceViewController

- (void)viewDidLoad{
    self.title = @"Adjust Distance";
    self.distanceSlider.value = 0.0;
    //default value is naked eye
    self.wearGlasses = @"Naked eye";

    [self.distanceSlider setThumbImage:[UIImage imageNamed:@"slider_dot.png"] forState:UIControlStateNormal];
    [self.distanceSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_indicator.png"] forState:UIControlStateNormal];
    [self.distanceSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_containder.png"] forState:UIControlStateNormal];
}


- (IBAction)onWearGlassesRadioButton:(RadioButton *)sender {
    NSLog(@"wear glasses selected: %@", sender.titleLabel.text);
    self.wearGlasses = sender.titleLabel.text;
}
- (IBAction)changeDistanceSlider:(id)sender {
    float distanceValue = self.distanceSlider.value * 3 +2;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f m", distanceValue];
}
- (CGRect)trackRectForBounds:(CGRect)bounds{
    return bounds;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DoneAdjustingDistance"]){
        if ([segue.destinationViewController isKindOfClass:[NewTestViewController class]]) {
            NewTestViewController *ntVC = (NewTestViewController*)segue.destinationViewController;
            ntVC.userName = self.userName;
            ntVC.meterValue = self.distanceSlider.value * 3 +2;
            ntVC.wearGlasses = self.wearGlasses;
        }
    }
}

@end

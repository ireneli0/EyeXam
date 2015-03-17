//
//  ViewProfileViewController.h
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewProfileViewController : UIViewController
@property (strong, nonatomic) NSString *userName;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wearGlassesLabel;
@property (weak, nonatomic) IBOutlet UILabel *EyesightTypeLabel;
@end

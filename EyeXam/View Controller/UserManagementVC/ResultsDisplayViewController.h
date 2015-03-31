//
//  ResultsDisplayViewController.h
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsDisplayViewController : UIViewController
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) IBOutlet UIButton *btn_NakedeyeResults;
@property (strong, nonatomic) IBOutlet UIButton *btn_WithglassedResults;

@end

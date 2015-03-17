//
//  ChangeUserViewController.h
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userInfo.h"

@interface ChangeUserViewController : UIViewController

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSMutableArray *allUsersArray;
@end

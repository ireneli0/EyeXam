//
//  PopoverSettingsViewController.h
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Node_iOS/Node.h>
#import <VTNodeConnectionHelper.h>

@interface PopoverSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *nodeSensorTableView;

@property (strong, nonatomic) VTNodeConnectionHelper *nodeConnectionHelper;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

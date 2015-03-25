//
//  NewTestViewController.h
//  EyeXam
//
//  Created by Yi on 2015-03-01.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Node_iOS/Node.h>
#import <VTNodeConnectionHelper.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "WYPopoverController.h"

@interface NewTestViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanForNodeSensorBarButtonItem;

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) VTNodeConnectionHelper *nodeConnectionHelper;
@property (strong, nonatomic) VTNodeDevice *connectedDevice;

@property (weak, nonatomic) IBOutlet UILabel *accelorometerLabel;
@property (weak, nonatomic) IBOutlet UILabel *gyroLabel;
@property (weak, nonatomic) IBOutlet UILabel *magnetometerLabel;

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *testFlowInstructionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eCharacterImageView;

//passed value through segue
@property (strong, nonatomic) NSString *userName;
@property (nonatomic)  float meterValue;
@property (strong, nonatomic) NSString * wearGlasses;

@end

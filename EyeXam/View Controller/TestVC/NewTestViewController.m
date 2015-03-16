//
//  NewTestViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-01.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "NewTestViewController.h"
#import "PopoverSettingsViewController.h"
#import "CoordinateAxesPoint.h"
#import <AudioToolbox/AudioToolbox.h>

@interface NewTestViewController ()<NodeDeviceDelegate,VTNodeConnectionHelperDelegate,WYPopoverControllerDelegate>{
    WYPopoverController *settingsPopoverController;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

//dynamic 9-axis
@property (nonatomic) float accX;
@property (nonatomic) float accY;
@property (nonatomic) float accZ;

@property (nonatomic) float gyroX;
@property (nonatomic) float gyroY;
@property (nonatomic) float gyroZ;

@property (nonatomic) float magX;
@property (nonatomic) float magY;
@property (nonatomic) float magZ;

//static 9-axis of original point
@property (nonatomic) float originAccX;
@property (nonatomic) float originAccY;
@property (nonatomic) float originAccZ;

@property (nonatomic) float originGyroX;
@property (nonatomic) float originGyroY;
@property (nonatomic) float originGyroZ;

@property (nonatomic) float originMagX;
@property (nonatomic) float originMagY;
@property (nonatomic) float originMagZ;



@property (weak, nonatomic) IBOutlet UILabel *x1Label;

@property (weak, nonatomic) IBOutlet UILabel *x2Label;


//Threads
@property (strong, nonatomic) NSCondition *condition;
//@property (strong, nonatomic) NSThread *aThread;
@property (nonatomic) BOOL lock;


//dynamic 9-axis
@property (strong, nonatomic) CoordinateAxesPoint *dynamicPoint;
//static 9-axis of original point
@property (strong, nonatomic) CoordinateAxesPoint *originalPoint;



//value for user input
@property (nonatomic) int userInputDirection;

//sounds
@property (nonatomic) SystemSoundID correct_soundID;
@property (nonatomic) SystemSoundID wrong_soundID;


//result
@property (nonatomic) float resultForRightEye;
@property (nonatomic) float resultForLeftEye;

@end

@implementation NewTestViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.lock = YES;
    self.condition = [[NSCondition alloc] init];
    self.spinner.hidden = YES;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.nodeConnectionHelper = [VTNodeConnectionHelper connectionHelperwithDelegate:self];
    //observer for peripheral
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNode:)
                                                 name:@"peripheral"
                                               object:nil];
    //observer for user direction
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUserInput:)
                                                 name:@"alreadyGotUserDirection"
                                               object:nil];
    self.title = @"New Test";
//    self.accelorometerLabel.hidden = YES;
//    self.gyroLabel.hidden = YES;
//    self.magnetometerLabel.hidden = YES;
//    self.x1Label.hidden = YES;
//    self.x2Label.hidden = YES;
    
    //initialize the sounds
    //correct sound
    NSString *correct_soundPath = [[NSBundle mainBundle]pathForResource:@"SoundResource/correct" ofType:@"wav"];
    NSURL *correct_soundURL = [NSURL fileURLWithPath:correct_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)correct_soundURL,&_correct_soundID);
    //wrong sound
    NSString *wrong_soundPath = [[NSBundle mainBundle]pathForResource:@"SoundResource/wrong" ofType:@"wav"];
    NSURL *wrong_soundURL = [NSURL fileURLWithPath:wrong_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)wrong_soundURL,&_wrong_soundID);
    
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"alreadyGotUserDirection" object:nil];
}

- (void)handleUserInput:(NSNotification *)notification{
    self.userInputDirection= [[[notification userInfo] objectForKey:@"inputDirection"] intValue];
    NSLog(@"1.got user input via notification: %d", self.userInputDirection);
    
    self.lock = NO;
    [self.condition signal];
    [self.condition unlock];
    
}

- (void)getNode:(NSNotification *)notification{
    //NSLog(@"get peripheral via notification");
    self.peripheral = [[notification userInfo] objectForKey:@"connectedPeripheral"];
    //NSLog(@"VC peripheral name:%@ ", self.peripheral.name);
    [self.nodeConnectionHelper connectDevice:self.peripheral forUseInBackground:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"peripheral" object:nil];
}

#pragma mark - NodeConnectionHelperDelegate
- (void) nodeConnectionHelperDidUpdateNodeDeviceList {
}
- (void) nodeConnectionHelperDidConnectToPeripheral:(CBPeripheral *)peripheral {
    //init connectedDevice with peripheral
    self.connectedDevice = [[VTNodeDevice alloc] initWithDelegate:self withDevice:peripheral];
}

#pragma mark - NodeDeviceDelegate
- (void) nodeDeviceIsReadyForCommunication:(VTNodeDevice *)device{
    self.connectedDevice.delegate = self;
    [self.connectedDevice setAccelerometerScale:VTNodeAccelerometerScale2g];
    [self.connectedDevice setGyroScale:VTNodeGyroScale1000dps];
    [self.connectedDevice setStreamModeAcc:YES Gyro:YES Mag:YES withPeriod:10 withLifetime:0 withTimestampingEnabled:YES];
    //-(void) setStreamModeAcc: (bool)aMode Gyro:(bool)gMode Mag:(bool)mMode withPeriod:(uint16_t)p withLifetime:(uint16_t)life withTimestampingEnabled: (bool) timestampingEnabled;
}

-(void) nodeDeviceButtonPushed: (VTNodeDevice *) device{
    self.originalPoint.accX = self.dynamicPoint.accX;
    self.originalPoint.accY = self.dynamicPoint.accY;
    self.originalPoint.accZ = self.dynamicPoint.accZ;
    
    self.originalPoint.gyroX = self.dynamicPoint.gyroX;
    self.originalPoint.gyroY = self.dynamicPoint.gyroY;
    self.originalPoint.gyroZ = self.dynamicPoint.gyroZ;
    
    self.originalPoint.magX = self.dynamicPoint.magX;
    self.originalPoint.magY = self.dynamicPoint.magY;
    self.originalPoint.magZ = self.dynamicPoint.magZ;
    
    NSLog(@"_______________________________________");
    NSLog(@"origin\n");
    NSLog(@"accx:%.2f, accy:%.2f, accz:%.2f", self.originalPoint.accX, self.originalPoint.accY, self.originalPoint.accZ);
    NSLog(@"gyrx:%.2f, gyry:%.2f, gyrz:%.2f", self.originalPoint.gyroX, self.originalPoint.gyroY, self.originalPoint.gyroZ);
    NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f", self.originalPoint.magX, self.originalPoint.magY, self.originalPoint.magZ);
    NSLog(@"_______________________________________");
    
    [self launchNewTest];
}

- (void) nodeDeviceDidUpdateAccReading:(VTNodeDevice *)device withReading:(VTSensorReading *)reading{
    self.accelorometerLabel.text = [NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",reading.x,reading.y,reading.z];
    self.dynamicPoint.accX = reading.x;
    self.dynamicPoint.accY = reading.y;
    self.dynamicPoint.accZ = reading.z;
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
    if (reading.x>1.38) {
        //up -> 3
        self.x1Label.text = [NSString stringWithFormat:@"x>1.38: %.3f", reading.x];
        [userDictionary setObject:[NSNumber numberWithInt:3] forKey:@"inputDirection"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
    }else if (reading.x<-0.1) {
        //down -> 2
        //self.x2Label.text  = [NSString stringWithFormat:@"x<-0.1: %.3f", reading.x];
        [userDictionary setObject:[NSNumber numberWithInt:2] forKey:@"inputDirection"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
    }
    else if (reading.y<-0.75) {
        //left -> 1
        self.x2Label.text  = [NSString stringWithFormat:@"y<-0.8: %.3f", reading.y];
        [userDictionary setObject:[NSNumber numberWithInt:1] forKey:@"inputDirection"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
    }
    
    
}

- (void)nodeDeviceDidUpdateGyroReading:(VTNodeDevice *)device withReading:(VTSensorReading *)reading{
    self.gyroLabel.text = [NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",reading.x,reading.y,reading.z];
    self.dynamicPoint.gyroX = reading.x;
    self.dynamicPoint.gyroY = reading.y;
    self.dynamicPoint.gyroZ = reading.z;
}

- (void)nodeDeviceDidUpdateMagReading:(VTNodeDevice *)device withReading:(VTSensorReading *)reading{
    self.magnetometerLabel.text =[NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",reading.x,reading.y,reading.z];
    self.dynamicPoint.magX = reading.x;
    self.dynamicPoint.magY = reading.y;
    self.dynamicPoint.magZ = reading.z;
}

#pragma mark - WYPopover
//close popover
- (void)close:(id)sender{
    [settingsPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:settingsPopoverController];
    }];
}

//open popover
- (IBAction)openPopoverView:(id)sender {
    [self showPopover:sender];
}

- (IBAction)showPopover:(id)sender{
    
    if (settingsPopoverController == nil){
        UIView *btn = (UIView *)sender;
        
        PopoverSettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PopoverSettingsViewController"];
        
        settingsViewController.preferredContentSize = CGSizeMake(300, 300);
        
        settingsViewController.title = @"Scanning for a NODE";
        
        [settingsViewController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)]];
        
        settingsViewController.modalInPopover = NO;
        
        UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        
        settingsPopoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
        
        settingsPopoverController.delegate = self;
        settingsPopoverController.passthroughViews = @[btn];
        settingsPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(100, 100, 100, 100);
        settingsPopoverController.wantsDefaultContentAppearance = NO;
        
        if (sender == self.scanForNodeSensorBarButtonItem){
            [settingsPopoverController presentPopoverFromBarButtonItem:self.scanForNodeSensorBarButtonItem permittedArrowDirections:WYPopoverArrowDirectionAny animated:NO];
        }
    }
    else{
        [self close:nil];
    }
}

#pragma mark - WYPopoverControllerDelegate
- (void)popoverControllerDidPresentPopover:(WYPopoverController *)controller{
    NSLog(@"popoverControllerDidPresentPopover");
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller{
    if (controller == settingsPopoverController){
        settingsPopoverController.delegate = nil;
        settingsPopoverController = nil;
    }
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController{
    return YES;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value{
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

#pragma mark - UIViewControllerRotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - E-character Direction Judgement
- (void) launchNewTest{
    //test for the right eye
    NSThread *aThread = [[NSThread alloc] initWithTarget:self selector:@selector(getOneEyeTested) object:nil];
    [aThread start];
    /*
     float resultForRightEye = [self getOneEyeTested];
     NSLog(@"result for right eye: %.2f", resultForRightEye);
     */
    
    //    UIAlertView *changeAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Now please change to the left eye." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [changeAlert show];
    //
    //    //change to the left eye
    // float resultForLeftEye = [self getOneEyeTested];
}

- (void)getOneEyeTested{
    NSThread *current = [NSThread currentThread];
    NSLog(@"current thread %@", current);
    
    [self.condition lock];
    
    float resultForEye = 0.0;
    float result[14] = {0.1, 0.12, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5, 2.0};
    //current row number
    int i = 0;
    int errorCount = 0;//range [0, 13]
    BOOL previousJudgement = TRUE;
    int randomDirection;
    
    do{
        [self.spinner startAnimating];
        //implement random direction of optotype E
        //randomDirection =  rand() % 4;
        randomDirection = rand()%3 + 1;
        //randomDirection = 2;
        NSLog(@"current Direction == %d, i = %d", randomDirection, i);
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
        UIImageOrientation imageOrientation = [self getImageOrientation:randomDirection];
        UIImage *imageTodisplay = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:imageOrientation];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eCharacterImageView setImage:imageTodisplay];
        });
        
        //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1]];
        
        //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        //wait for node sensor motion
        //..
        //..
        
        while(self.lock)
        {
            NSLog(@"Will Wait");
            [self.condition wait];
            
            // the "did wait" will be printed only when you have signaled the condition change in the sendNewEvent method
            NSLog(@"Did Wait");
        }
        NSLog(@"2. userinput direction is %d", self.userInputDirection);
        
        self.lock = YES;
        [self.condition unlock];
        
        if(self.userInputDirection == randomDirection){
            //Correct judgement
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *correctImage = [UIImage imageNamed:@"correct.png"];
                [self.eCharacterImageView setImage:correctImage];
                AudioServicesPlaySystemSound(_correct_soundID);
                [self.spinner stopAnimating];
            });
            //wait for the indicating image loading
            [NSThread sleepForTimeInterval:0.4];
            if (errorCount == 0 && previousJudgement == true) {
                i++;
                continue;
            }else if (errorCount > 0 && previousJudgement == true){
                i++;
                break;
            }else if (errorCount > 0 && previousJudgement == false){
                previousJudgement = true;
                continue;
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *wrongImage = [UIImage imageNamed:@"wrong.jpg"];
                [self.eCharacterImageView setImage:wrongImage];
                AudioServicesPlaySystemSound(_wrong_soundID);
                [self.spinner stopAnimating];
            });
            [NSThread sleepForTimeInterval:0.8];
            
            //Wrong judgement
            i--;
            errorCount++;
            previousJudgement = false;
            continue;
        }
    }while(i>=0&&i<=13);
    
    
    if (i == -1) {
        resultForEye = 0.01;
    }else{
        resultForEye = result[i-1];
    }
    NSLog(@"result for eye is :%.2f", resultForEye);
    self.resultForRightEye = resultForEye;
    NSString *resultString = [NSString stringWithFormat:@"Your test result is:%.2f.\nWould you like to save it?", resultForEye];
    
    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Finished!" message:resultString delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No, thanks" ,nil];
    [saveAlert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"Action for saving results waiting to be implemented...");
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (UIImageOrientation) getImageOrientation: (int)randomDirection{
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    switch (randomDirection) {
        case 0:
            imageOrientation = UIImageOrientationUp;
            break;
        case 1:
            imageOrientation = UIImageOrientationDown;
            break;
        case 2:
            imageOrientation = UIImageOrientationRight;
            break;
        case 3:
            imageOrientation = UIImageOrientationLeft;
            break;
        default:
            
            break;
    }
    return imageOrientation;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([segue.identifier isEqualToString:@"CurrentTestResultDisplay"]) {
//        if ([segue.destinationViewController isKindOfClass:[CurrentTestResultDisplayViewController class]]) {
//            CurrentTestResultDisplayViewController *ctrdVC = (CurrentTestResultDisplayViewController *)segue.destinationViewController;
//            ctrdVC.result = self.resultForRightEye;
//        }
//    }
//}

@end

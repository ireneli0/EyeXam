//
//  NewTestViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-01.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "NewTestViewController.h"
#import "PopoverSettingsViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DatabaseInstance.h"

@interface NewTestViewController ()<NodeDeviceDelegate,VTNodeConnectionHelperDelegate,WYPopoverControllerDelegate>{
    WYPopoverController *settingsPopoverController;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

//dynamic 9-axis
@property (nonatomic) float magX;
@property (nonatomic) float magY;
@property (nonatomic) float magZ;

//static 9-axis of original point
@property (nonatomic) float originMagX;
@property (nonatomic) float originMagY;
@property (nonatomic) float originMagZ;

//up
@property (nonatomic) float upOriginMagX;
@property (nonatomic) float upOriginMagY;
@property (nonatomic) float upOriginMagZ;
//down
@property (nonatomic) float downOriginMagX;
@property (nonatomic) float downOriginMagY;
@property (nonatomic) float downOriginMagZ;
//left
@property (nonatomic) float leftOriginMagX;
@property (nonatomic) float leftOriginMagY;
@property (nonatomic) float leftOriginMagZ;
//right
@property (nonatomic) float rightOriginMagX;
@property (nonatomic) float rightOriginMagY;
@property (nonatomic) float rightOriginMagZ;


//Threads
@property (strong, nonatomic) NSCondition *condition;
@property (nonatomic) BOOL lock;
@property (strong, nonatomic) NSThread *aThread;

//value for user input
@property (nonatomic) int userInputDirection;
@property (strong, nonatomic) UIAlertView* changeEyeAlert;
@property (nonatomic) int testFlowFlag;
@property (nonatomic) int buttonPressedCount;

//sounds
@property (nonatomic) SystemSoundID correct_soundID;
@property (nonatomic) SystemSoundID wrong_soundID;
@property (nonatomic) SystemSoundID calibration_soundID;
@property (nonatomic) SystemSoundID up_soundID;
@property (nonatomic) SystemSoundID down_soundID;
@property (nonatomic) SystemSoundID left_soundID;
@property (nonatomic) SystemSoundID right_soundID;
@property (nonatomic) SystemSoundID starttest_soundID;
@property (nonatomic) SystemSoundID changeeye_soundID;
@property (nonatomic) SystemSoundID testcompleted_soundID;

//result
@property (nonatomic) float resultForRightEye;
@property (nonatomic) float resultForLeftEye;

//imageView
@property (strong, nonatomic) UIImageView* eCharacterImageView;
@property (strong, nonatomic) UIImageView* instructionImageView;

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
    self.buttonPressedCount = -5;
    self.testFlowFlag = -1;
    self.resultForLeftEye =0;
    self.resultForRightEye = 0;
    
    self.accelorometerLabel.hidden = YES;
    self.gyroLabel.hidden = YES;
    self.magnetometerLabel.hidden = YES;
    self.instructionLabel.hidden = YES;
    self.testFlowInstructionLabel.hidden = YES;
    

    //initialize instructionImageView
    self.instructionImageView  =[[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 1024, 768)];
    [self.view addSubview:self.instructionImageView];
    
    self.instructionLabel.text = [NSString stringWithFormat:@"Please stand away %.1f meters from the screen.", self.meterValue];
    
    //initialize eCharacterImageView
    self.eCharacterImageView =[[UIImageView alloc] initWithFrame:CGRectMake(350,280,500,500)];
    [self.view addSubview:self.eCharacterImageView];
    
    //initialize the sounds
    //correct sound
    NSString *correct_soundPath = [[NSBundle mainBundle]pathForResource:@"SoundResource/correct" ofType:@"wav"];
    NSURL *correct_soundURL = [NSURL fileURLWithPath:correct_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)correct_soundURL,&_correct_soundID);
    //wrong sound
    NSString *wrong_soundPath = [[NSBundle mainBundle]pathForResource:@"SoundResource/wrong" ofType:@"wav"];
    NSURL *wrong_soundURL = [NSURL fileURLWithPath:wrong_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)wrong_soundURL,&_wrong_soundID);
    
    //start calibration phrase
    NSString *calibration_soundPath = [[NSBundle mainBundle]pathForResource:@"calibration" ofType:@"wav"];
    NSURL *calibration_soundURL = [NSURL fileURLWithPath:calibration_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)calibration_soundURL,&_calibration_soundID);
    
    //up
    NSString *up_soundPath = [[NSBundle mainBundle]pathForResource:@"up" ofType:@"wav"];
    NSURL *up_soundURL = [NSURL fileURLWithPath:up_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)up_soundURL,&_up_soundID);
    //down
    NSString *down_soundPath = [[NSBundle mainBundle]pathForResource:@"down" ofType:@"wav"];
    NSURL *down_soundURL = [NSURL fileURLWithPath:down_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)down_soundURL,&_down_soundID);
    //left
    NSString *left_soundPath = [[NSBundle mainBundle]pathForResource:@"left" ofType:@"wav"];
    NSURL *left_soundURL = [NSURL fileURLWithPath:left_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)left_soundURL,&_left_soundID);
    //right
    NSString *right_soundPath = [[NSBundle mainBundle]pathForResource:@"right" ofType:@"wav"];
    NSURL *right_soundURL = [NSURL fileURLWithPath:right_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)right_soundURL,&_right_soundID);
    
    //start Test
    NSString *starttest_soundPath = [[NSBundle mainBundle]pathForResource:@"starttest" ofType:@"wav"];
    NSURL *starttest_soundURL = [NSURL fileURLWithPath:starttest_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)starttest_soundURL,&_starttest_soundID);
    //change Eye
    NSString *changeeye_soundPath = [[NSBundle mainBundle]pathForResource:@"changeeye" ofType:@"wav"];
    NSURL *changeeye_soundURL = [NSURL fileURLWithPath:changeeye_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)changeeye_soundURL,&_changeeye_soundID);
    
    //test completed
    NSString *testcompleted_soundPath = [[NSBundle mainBundle]pathForResource:@"testcompleted" ofType:@"mp3"];
    NSURL *testcompleted_soundURL = [NSURL fileURLWithPath:testcompleted_soundPath];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)testcompleted_soundURL,&_changeeye_soundID);
    
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"alreadyGotUserDirection" object:nil];
}

- (void)handleUserInput:(NSNotification *)notification{
    self.userInputDirection= [[[notification userInfo] objectForKey:@"inputDirection"] intValue];
    self.lock = NO;
    [self.condition signal];
    //[self.condition unlock];
    
}

- (void)getNode:(NSNotification *)notification{
    self.peripheral = [[notification userInfo] objectForKey:@"connectedPeripheral"];
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
    
}

-(void) nodeDeviceButtonPushed: (VTNodeDevice *) device{
    switch (self.testFlowFlag) {
            
        case -1:
            //calibrating phrase
            if(self.buttonPressedCount == -5){
                //start calibrating
                self.testFlowInstructionLabel.text =@"Calibrating...->up";
                [self.instructionImageView setImage:[UIImage imageNamed:@"up_indicator.PNG"]];
                AudioServicesPlaySystemSound(_up_soundID);
                self.buttonPressedCount ++;
            
            }else if(self.buttonPressedCount == -4){
                //original up axes value
                self.testFlowInstructionLabel.text =@"Calibrating...->down";
                [self.instructionImageView setImage:[UIImage imageNamed:@"down_indicator.PNG"]];
                AudioServicesPlaySystemSound(_down_soundID);
                self.upOriginMagX = self.magX;
                self.upOriginMagY = self.magY;
                self.upOriginMagZ = self.magZ;
                NSLog(@"up calibrating phrase\n");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f_____origin_up", self.upOriginMagX, self.upOriginMagY, self.upOriginMagZ);
                self.buttonPressedCount ++;
            }else if(self.buttonPressedCount == -3){
                self.testFlowInstructionLabel.text =@"Calibrating...->left";
                [self.instructionImageView setImage:[UIImage imageNamed:@"left_indicator.PNG"]];
                AudioServicesPlaySystemSound(_left_soundID);
                self.downOriginMagX = self.magX;
                self.downOriginMagY = self.magY;
                self.downOriginMagZ = self.magZ;
                NSLog(@"down calibrating phrase");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f_____origin_down", self.downOriginMagX, self.downOriginMagY, self.downOriginMagZ);
                self.buttonPressedCount ++;
            }else if(self.buttonPressedCount == -2){
                self.testFlowInstructionLabel.text =@"Calibrating...->right";
                [self.instructionImageView setImage:[UIImage imageNamed:@"right_indicator.PNG"]];
                AudioServicesPlaySystemSound(_right_soundID);
                self.leftOriginMagX = self.magX;
                self.leftOriginMagY = self.magY;
                self.leftOriginMagZ = self.magZ;
                NSLog(@"left calibrating phrase");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f_____origin_left", self.leftOriginMagX, self.leftOriginMagY, self.leftOriginMagZ);
                self.buttonPressedCount ++;
            }else if (self.buttonPressedCount == -1){
                self.testFlowInstructionLabel.text =@"Calibrating phrase completed!";
                AudioServicesPlaySystemSound(_starttest_soundID);
                [self.instructionImageView removeFromSuperview];
                self.rightOriginMagX = self.magX;
                self.rightOriginMagY = self.magY;
                self.rightOriginMagZ = self.magZ;
                NSLog(@"right calibrating phrase");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f_____origin_right", self.rightOriginMagX, self.rightOriginMagY, self.rightOriginMagZ);
                self.buttonPressedCount ++;
                self.testFlowFlag ++;
            }
                
            
            break;
        case 0:
            //1st testing phrase:right
            self.testFlowInstructionLabel.text =@"Testing right eye...";

            if (self.buttonPressedCount ==0) {
                //1st time press button
                self.originMagX = self.magX;
                self.originMagY = self.magY;
                self.originMagZ = self.magZ;
                
                NSLog(@"%i testing phrase", self.testFlowFlag+1);
                NSLog(@"origin\n");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f_____origin1", self.originMagX, self.originMagY, self.originMagZ);
                
                self.buttonPressedCount ++;

                [self launchNewTest];
            }else{
                
                NSLog(@"dynamic\n");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f", self.magX, self.magY, self.magZ);
                NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];

                if (fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magZ-self.leftOriginMagZ)<0.05) {
                    //left->1
                    [userDictionary setObject:[NSNumber numberWithInt:1] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"left");
                }else if(fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magZ-self.rightOriginMagZ)<0.05){
                    //right->0
                    [userDictionary setObject:[NSNumber numberWithInt:0] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"right");
                }else if(fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magY-self.upOriginMagY)<0.05){
                    //up -> 3
                    [userDictionary setObject:[NSNumber numberWithInt:3] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"up");
                }else if(fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magY-self.downOriginMagY)<0.05){
                    //down -> 2
                    [userDictionary setObject:[NSNumber numberWithInt:2] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"down");
                }
            }

            break;
        case 1:
            //2nd testing phrase:left
            self.testFlowInstructionLabel.text =@"Testing left eye...";
            
            if (self.buttonPressedCount ==0) {
                //1st time press button
                [self.changeEyeAlert dismissWithClickedButtonIndex:0 animated:NO];
                self.originMagX = self.magX;
                self.originMagY = self.magY;
                self.originMagZ = self.magZ;
                
                NSLog(@"%i testing phrase", self.testFlowFlag+1);
                NSLog(@"origin\n");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f_____origin2", self.originMagX, self.originMagY, self.originMagZ);
                
                self.buttonPressedCount ++;
                
                [self launchNewTest];
            }else{
                
                NSLog(@"dynamic_2\n");
                NSLog(@"magx:%.2f, magy:%.2f, magz:%.2f", self.magX, self.magY, self.magZ);
                NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
                
                if (fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magZ-self.leftOriginMagZ)<0.05) {
                    //left->1
                    [userDictionary setObject:[NSNumber numberWithInt:1] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"left");
                }else if(fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magZ-self.rightOriginMagZ)<0.05){
                    //right->0
                    [userDictionary setObject:[NSNumber numberWithInt:0] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"right");
                }else if(fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magY-self.upOriginMagY)<0.05){
                    //up -> 3
                    [userDictionary setObject:[NSNumber numberWithInt:3] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"up");
                }else if(fabsf(self.magX -self.originMagX)>0.2&&fabsf(self.magY-self.downOriginMagY)<0.05){
                    //down -> 2
                    [userDictionary setObject:[NSNumber numberWithInt:2] forKey:@"inputDirection"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyGotUserDirection" object:nil userInfo:userDictionary];
                    NSLog(@"down");
                }

            }

            break;
        case 2:
            break;
        default:
            break;
    }
    
    
    
}

- (void) nodeDeviceDidUpdateAccReading:(VTNodeDevice *)device withReading:(VTSensorReading *)reading{
    self.accelorometerLabel.text = [NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",reading.x,reading.y,reading.z];
}

- (void)nodeDeviceDidUpdateGyroReading:(VTNodeDevice *)device withReading:(VTSensorReading *)reading{
    self.gyroLabel.text = [NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",reading.x,reading.y,reading.z];
}

- (void)nodeDeviceDidUpdateMagReading:(VTNodeDevice *)device withReading:(VTSensorReading *)reading{
    self.magnetometerLabel.text =[NSString stringWithFormat:@"x:%.2f,y:%.2f,z:%.2f",reading.x,reading.y,reading.z];
    self.magX = reading.x;
    self.magY = reading.y;
    self.magZ = reading.z;
}

#pragma mark - WYPopover
//close popover
- (void)close:(id)sender{
    [settingsPopoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:settingsPopoverController];
        AudioServicesPlaySystemSound(_calibration_soundID);
        
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
        
        settingsViewController.title = @"Scan NODE";
        
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
    //test for one eye
    self.aThread = [[NSThread alloc] initWithTarget:self selector:@selector(getOneEyeTested) object:nil];
    [self.aThread start];
}

- (void)getOneEyeTested{
    NSThread *current = [NSThread currentThread];
    NSLog(@"current thread %@", current);
    [self.condition lock];
    
    float resultForEye = 0.0;
    float result[14] = {0.1, 0.125, 0.16, 0.2, 0.25, 0.32, 0.4, 0.5, 0.63, 0.8, 1.0, 1.25, 1.6, 2.0};
    //current row number
    int i = 0;
    int errorCount = 0;//range [0, 13]
    BOOL previousJudgement = TRUE;
    int randomDirection;
    
    do{
        [self.spinner startAnimating];
        
        //implement random direction of optotype E
        randomDirection =  rand() % 4;
        
        //set up the location of UIImageView
        float offset_x = 399 - (self.meterValue - 2)*43;
        float offset_y = 300 - (self.meterValue - 2)*33;
        NSLog(@"current Direction == %d, i = %d", randomDirection, i);
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", i]];
        UIImageOrientation imageOrientation = [self getImageOrientation:randomDirection];
        
        //adjust the size of optotype with distance
        float optotypesize = self.meterValue/2*200;
        UIImage *resizeImage = [NewTestViewController imageWithImage:image scaledToSize:CGSizeMake(optotypesize, optotypesize)];
        UIImage *imageTodisplay = [UIImage imageWithCGImage:[resizeImage CGImage] scale:1.0 orientation:imageOrientation];
        self.eCharacterImageView.frame = CGRectMake(offset_x,offset_y,imageTodisplay.size.width/2, imageTodisplay.size.height/2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eCharacterImageView setImage:imageTodisplay];
        });
        

        while(self.lock){
            //wait for node sensor motion
            NSLog(@"Will Wait");
            [self.condition wait];
            
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
            [NSThread sleepForTimeInterval:0.8];
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
            [NSThread sleepForTimeInterval:0.5];
            
            //Wrong judgement
            i--;
            errorCount++;
            previousJudgement = false;
            continue;
        }
    }while(i>=0&&i<=13);
    
    
    if (i == -1) {
        resultForEye = 0.1;
    }else{
        resultForEye = result[i-1];
    }
    NSLog(@"result for eye is :%.3f", resultForEye);
    self.testFlowFlag ++;
    self.buttonPressedCount = 0;
    
    if(self.testFlowFlag ==1){
        self.resultForRightEye = resultForEye;
        NSString *resultString = [NSString stringWithFormat:@"Pressed the button on your NODE device to continue"];
        
        self.changeEyeAlert = [[UIAlertView alloc] initWithTitle:@"Change to left eye!" message:resultString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.changeEyeAlert.tag = 0;
        [self.changeEyeAlert show];
        AudioServicesPlaySystemSound(_changeeye_soundID);

    }else if(self.testFlowFlag ==2){
        self.resultForLeftEye = resultForEye;
        
        //standardize the display form of results
        int resultRight = ceil(20/self.resultForRightEye);
        int resultLeft = ceil(20/self.resultForLeftEye);
        
        NSString *resultString = [NSString stringWithFormat:@"Your test result is:\nright:20/%d\nleft:20/%d\nWould you like to save it?", resultRight,resultLeft];
        
        self.testFlowInstructionLabel.text = @"Completed!";
        UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Completed!" message:resultString delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No, thanks" ,nil];
        saveAlert.tag = 1;
        [saveAlert show];
        AudioServicesPlaySystemSound(_testcompleted_soundID);
    }
        //after finishing testing one eye, cancel the thread
    [self.aThread cancel];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 0:
            break;
        case 1:
            if (buttonIndex == 0) {
                
                int resultRight = 20/self.resultForRightEye;
                int resultLeft = 20/self.resultForLeftEye;
                
                NSString *testMeters = [NSString stringWithFormat:@"%.1f", self.meterValue];
                NSString *lefteyeResult = [NSString stringWithFormat:@"20/%d", resultLeft];
                NSString *righteyeResult = [NSString stringWithFormat:@"20/%d", resultRight];
                
                NSString *currenttime;
                NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
                currenttime = [formatter stringFromDate:[NSDate date]];
                
                if([[DatabaseInstance getSharedInstance]addNewRecords:@"Records" withName:self.userName withtestMeter:testMeters withGlasses:self.wearGlasses withlefteyeResult:lefteyeResult withrighteyeResult:righteyeResult withTime:currenttime]){
                    NSLog(@"update Records succeessfully");
                }
                
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
            }
            if (buttonIndex == 1) {
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
            }
            break;
        default:
            break;
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

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

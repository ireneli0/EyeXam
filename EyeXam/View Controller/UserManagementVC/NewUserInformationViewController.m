//
//  NewUserInformationViewController.m
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "NewUserInformationViewController.h"
#import "RadioButton.h"
#import "AppDelegate.h"
#import "DatabaseInstance.h"
#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface NewUserInformationViewController ()

@end

@implementation NewUserInformationViewController

-(void)viewDidLoad{

    self.userNameTextField.delegate = self;
    
    self.userNameTextField.layer.cornerRadius=8.0f;
    self.userNameTextField.layer.masksToBounds=YES;
    self.userNameTextField.layer.borderColor=[UIColorFromRGB(0xababab) CGColor];
    self.userNameTextField.layer.borderWidth= 2.0f;
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.userNameTextField.layer.borderColor=[UIColorFromRGB(0x1abc9c) CGColor];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.userNameTextField.layer.borderColor=[UIColorFromRGB(0xababab) CGColor];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)onWearGlassesRadioButton:(RadioButton *)sender {
    //NSLog(@"wear glasses selected: %@", sender.titleLabel.text);
    self.wearGlasses = sender.titleLabel.text;

}

- (IBAction)onEyeTypeRadioButton:(RadioButton *)sender {
    //NSLog(@"Eye type selected: %@", sender.titleLabel.text);
    self.eyesightType = sender.titleLabel.text;
}

- (IBAction)signUp:(id)sender {
    NSLog(@"wearGlasses: %@, eyetype: %@", self.wearGlasses, self.eyesightType);
    if ([self.eyesightType length] != 0&&[self.wearGlasses length]!=0 &&[self.userNameTextField.text length] !=0) {
        //create tables
        if([[DatabaseInstance getSharedInstance]createTables]){
            NSLog(@"create table successfully");
        }
        self.user = self.userNameTextField.text;
        
        if(![[DatabaseInstance getSharedInstance]checkNewUserisExists:self.user]){
            //username does not exist
            if([[DatabaseInstance getSharedInstance]addNewUser:@"Users" withName:self.user withGlasses:self.wearGlasses withEyetype:self.eyesightType]){
                NSLog(@"insert successfully");
                UIAlertView *signUpSucceed = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You signed up a new account successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [signUpSucceed show];
                
                //post username string through NSUserDefaults
                [[NSUserDefaults standardUserDefaults]setObject:self.userNameTextField.text forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //signup successfully -> jump to the main VC
                AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
                appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

            }
        }else{
            //user name has already existed
            NSLog(@"User has already exits");
            UIAlertView *corruptedUserName = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Someone already has that username!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [corruptedUserName show];

        }
    }else if([self.userNameTextField.text length]==0){
        UIAlertView *nullUserNameAlert = [[UIAlertView alloc] initWithTitle:@"Empty user name!" message:@"Please input a valid user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [nullUserNameAlert show];
    }else if([self.wearGlasses length]==0){
        UIAlertView *nullWearGlassesAlert = [[UIAlertView alloc] initWithTitle:@"Empty Choice" message:@"Please choose your glasses condition!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [nullWearGlassesAlert show];
    }else if ([self.eyesightType length] ==0){
        UIAlertView *nullEyeSightTypeAlert = [[UIAlertView alloc] initWithTitle:@"Empty Choice" message:@"Please choose your eyesight type!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [nullEyeSightTypeAlert show];
    }
}

@end

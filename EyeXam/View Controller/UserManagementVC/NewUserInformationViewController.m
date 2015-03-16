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
@interface NewUserInformationViewController ()

@property (strong, nonatomic) NSString * wearGlasses;
@property (strong, nonatomic) NSString * eyesightType;

@end

@implementation NewUserInformationViewController

-(void)viewDidLoad{
    self.userNameTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)onWearGlassesRadioButton:(RadioButton *)sender {
    NSLog(@"wear glasses selected: %@", sender.titleLabel.text);
    self.wearGlasses = sender.titleLabel.text;

}

- (IBAction)onEyeTypeRadioButton:(RadioButton *)sender {
    NSLog(@"Eye type selected: %@", sender.titleLabel.text);
    self.eyesightType = sender.titleLabel.text;
}

- (IBAction)signUp:(id)sender {
    NSLog(@"wearGlasses: %@, eyetype: %@", self.wearGlasses, self.eyesightType);
    if ([self.eyesightType length] != 0&&[self.wearGlasses length]!=0 &&[self.userNameTextField.text length] !=0) {
        UIAlertView *signUpSucceed = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You signed up a new account successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [signUpSucceed show];
        
        //here to write user info into database
        //..
        //..
        //..
        
        
        //post signup successfully notificatoin with username string
        [[NSUserDefaults standardUserDefaults]setObject:self.userNameTextField.text forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"username saved = %@", self.userNameTextField.text);
        
        
        //signup successfully
        //jump to the main VC
        AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
        appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

    }else if([self.userNameTextField.text length]==0){
        UIAlertView *nullUserNameAlert = [[UIAlertView alloc] initWithTitle:@"Empty user name!" message:@"Please input a valid user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [nullUserNameAlert show];
    }else if([self.wearGlasses length]==0){
        UIAlertView *nullWearGlassesAlert = [[UIAlertView alloc] initWithTitle:@"Empty Choice" message:@"Please choose your glasses condition!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [nullWearGlassesAlert show];
    }else if ([self.eyesightType length] ==0){
        UIAlertView *nullEyeSightTypeAlert = [[UIAlertView alloc] initWithTitle:@"Empty Choice" message:@"Please choose your eyesight type!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [nullEyeSightTypeAlert show];
    }else{
        //check corrupted username
        //wait to be implemented
    }
}



@end

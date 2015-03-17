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

@interface NewUserInformationViewController ()

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
        
        self.user = self.userNameTextField.text;
        NSLog(@"%d",[[DatabaseInstance getSharedInstance]checkNewUserisExists:self.user]);
        NSLog(@"%@",self.user);
        
        if(![[DatabaseInstance getSharedInstance]checkNewUserisExists:self.user]){
            
            if([[DatabaseInstance getSharedInstance]createTables]&&
               [[DatabaseInstance getSharedInstance]addNewUser:@"Users" withName:self.user withGlasses:self.wearGlasses withEyetype:self.eyesightType]){
                NSLog(@"create success");
                UIAlertView *signUpSucceed = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You signed up a new account successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [signUpSucceed show];
                
                //write user info into database

                
                //post username string through NSUserDefaults
                [[NSUserDefaults standardUserDefaults]setObject:self.userNameTextField.text forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //signup successfully -> jump to the main VC
                AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
                appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

            }
        }else{
            //user name has already exists
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
    }else{
        //check corrupted username
        //wait to be implemented
    }
}



@end

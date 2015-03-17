//
//  ChangeUserViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ChangeUserViewController.h"
#import "DatabaseInstance.h"

@interface ChangeUserViewController ()
@property (weak, nonatomic) IBOutlet UITableView *allUsersTableView;

@end

@implementation ChangeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Change User";
    self.allUsersTableView.allowsMultipleSelectionDuringEditing = NO;
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allUsersArray count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
     userInfo *userInfo =[self.allUsersArray objectAtIndex:indexPath.row];
     cell.textLabel.text = userInfo.userName;
 
     return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        userInfo *userInfo =[self.allUsersArray objectAtIndex:indexPath.row];
        NSLog(@"self.userName:%@, userInfo.userName:%@", self.userName, userInfo.userName);
        if([self.userName isEqualToString: userInfo.userName]){
            //cannot delete current user himself
            UIAlertView *deleteCurrentUserAlert = [[UIAlertView alloc]
                                            initWithTitle:@"Alert" message:@"You cannot delete yourself" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [deleteCurrentUserAlert show];
            
        }else{
        
            [[DatabaseInstance getSharedInstance] deleteSelectedUser:userInfo.userName];
            [self.allUsersArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    userInfo *userInfo = [self.allUsersArray objectAtIndex:indexPath.row];
    if([self.userName isEqualToString:userInfo.userName]){
        //do nothing if choose to change to current user
    }else{
    UIAlertView *changeUserAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Change Account" message:@"Are you sure you want to change to this account?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    [changeUserAlert show];
    self.userName = userInfo.userName;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    }else if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject: self.userName forKey: @"userName"];
        NSLog(@"change to user :%@", self.userName);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end

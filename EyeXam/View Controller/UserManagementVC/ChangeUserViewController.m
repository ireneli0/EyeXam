//
//  ChangeUserViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ChangeUserViewController.h"

@interface ChangeUserViewController ()
@property (weak, nonatomic) IBOutlet UITableView *allUsersTableView;

@end

@implementation ChangeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Change User";
    self.allUsersTableView.allowsMultipleSelectionDuringEditing = NO;
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
        //hit delete
        //here to add database delete code
        //..
        //..
        //..
        [self.allUsersArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *changeUserAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Change Account" message:@"Are you sure you want to change to this account?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    [changeUserAlert show];
    userInfo *userInfo = [self.allUsersArray objectAtIndex:indexPath.row];
    self.userName = userInfo.userName;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    }else if (buttonIndex == 1) {
        //[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
        
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

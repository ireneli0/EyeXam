//
//  ResultsDisplayViewController.m
//  EyeXam
//
//  Created by Yi on 2015-03-17.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "ResultsDisplayViewController.h"
#import "DatabaseInstance.h"
#import "allRecords.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface ResultsDisplayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *nakedEyeResultDisplayTable;
@property (weak, nonatomic) IBOutlet UITableView *withGlassesResultDisplayTable;

@end

@implementation ResultsDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController setTitle:@"Results Display"];
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    self.userNameLabel.text = self.userName;
    //set attributes to button
    self.btn_NakedeyeResults.layer.borderColor = UIColorFromRGB(0x1ABC9C).CGColor;
    self.btn_NakedeyeResults.layer.borderWidth = 0.5;
    self.btn_NakedeyeResults.layer.cornerRadius = 10;
    [self.btn_NakedeyeResults addTarget:self action:@selector(showNakedeyeResults:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_WithglassedResults.layer.borderColor = UIColorFromRGB(0x1ABC9C).CGColor;
    self.btn_WithglassedResults.layer.borderWidth = 0.5;
    self.btn_WithglassedResults.layer.cornerRadius = 10;
    [self.btn_WithglassedResults addTarget:self action:@selector(showWithglassesResults:) forControlEvents:UIControlEventTouchUpInside];
    
    //initial displaying results
    self.btn_NakedeyeResults.backgroundColor = UIColorFromRGB(0x1ABC9C);
    [self.btn_NakedeyeResults setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nakedEyeResultDisplayTable.hidden = false;
    self.withGlassesResultDisplayTable.hidden = true;
}

-(IBAction)showNakedeyeResults:(id)sender{
    //change color attributes to buttons
    self.btn_NakedeyeResults.backgroundColor = UIColorFromRGB(0x1ABC9C);
    [self.btn_NakedeyeResults setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    self.btn_WithglassedResults.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.btn_WithglassedResults setTitleColor:UIColorFromRGB(0x1ABC9C) forState:UIControlStateNormal];
    //change the results to be displayed
    self.nakedEyeResultDisplayTable.hidden = false;
    self.withGlassesResultDisplayTable.hidden = true;
}

-(IBAction)showWithglassesResults:(id)sender{
    //change color attributes to buttons
    self.btn_NakedeyeResults.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.btn_NakedeyeResults setTitleColor:UIColorFromRGB(0x1ABC9C) forState:UIControlStateNormal];
    self.btn_WithglassedResults.backgroundColor = UIColorFromRGB(0x1ABC9C);
    [self.btn_WithglassedResults setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //change the results to be displayed
    self.nakedEyeResultDisplayTable.hidden = true;
    self.withGlassesResultDisplayTable.hidden = false;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView.tag ==0){
        //naked eye
        return [[[DatabaseInstance getSharedInstance]getNakedEyeRecordsForSelectedUser:self.userName] count];

    }else if (tableView.tag ==1){
        //glasses eye
        return [[[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName] count];
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag == 0){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            NSMutableArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
            allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:indexPath.row];
            [[DatabaseInstance getSharedInstance] deleteSelectedRecord:self.userName :recordsForCurrentUser.currentTime];
            [nakedEyeResultsArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }
    else{
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            NSMutableArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
            allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:indexPath.row];
            [[DatabaseInstance getSharedInstance] deleteSelectedRecord:self.userName :recordsForCurrentUser.currentTime];
            [withGlassesResultsArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = nil;
     if(tableView.tag ==0){
         //naked eye result cell
         cell = [tableView dequeueReusableCellWithIdentifier:@"nakedEyeResultsTableCell"  forIndexPath:indexPath];
         NSArray *nakedEyeResultsArray = [[DatabaseInstance getSharedInstance] getNakedEyeRecordsForSelectedUser:self.userName];
         allRecords *recordsForCurrentUser = [nakedEyeResultsArray objectAtIndex:indexPath.row];
         cell.textLabel.text = [NSString stringWithFormat:@"    Result for  Left Eye: %@,   Right Eye: %@,  Distance: %@m",  recordsForCurrentUser.lefteyeResult, recordsForCurrentUser.righteyeResult, recordsForCurrentUser.testMeters];
         cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:18.0f];
         cell.detailTextLabel.text = [NSString stringWithFormat:@"         Tested at %@", recordsForCurrentUser.currentTime];
         cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:12.0f];

     }else if (tableView.tag ==1){//
         //with glasses eye result cell
         cell = [tableView dequeueReusableCellWithIdentifier:@"withGlassesResultsTableCell" forIndexPath:indexPath];
         NSArray *withGlassesResultsArray = [[DatabaseInstance getSharedInstance] getWithGlassesRecordsForSelectedUser:self.userName];
         allRecords *recordsForCurrentUser = [withGlassesResultsArray objectAtIndex:indexPath.row];
         cell.textLabel.text = [NSString stringWithFormat:@"    Result for  Left Eye: %@,   Right Eye: %@,  Distance: %@m",  recordsForCurrentUser.lefteyeResult, recordsForCurrentUser.righteyeResult, recordsForCurrentUser.testMeters];
         cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:18.0f];
         cell.detailTextLabel.text = [NSString stringWithFormat:@"         Tested at %@", recordsForCurrentUser.currentTime];
         cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:12.0f];
     }
     return cell;
}


@end

//
//  PopoverSettingsViewController.m
//  EyeXam
//
//  Created by Yi on 2015-02-25.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "PopoverSettingsViewController.h"

@interface PopoverSettingsViewController ()<UITableViewDataSource, UITableViewDelegate,VTNodeConnectionHelperDelegate,NodeDeviceDelegate>

@end

@implementation PopoverSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:195./255. green:4./255. blue:94./255. alpha:1.]];
    
    
    self.nodeConnectionHelper = [VTNodeConnectionHelper connectionHelperwithDelegate:self];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshDeviceList:)
                  forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    
    [self.nodeSensorTableView addSubview:self.refreshControl];
}


#pragma mark - Refreshing
-(void)refreshDeviceList:(UIRefreshControl *)refresh {
    [self.nodeConnectionHelper startScanAndRetrievalOfPeripherals];
}

- (void) nodeConnectionHelperDidFinishScanning {
    [self.refreshControl endRefreshing];
}

- (void) nodeConnectionHelperDidUpdateNodeDeviceList {
    [self.nodeSensorTableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section{
    return self.nodeConnectionHelper.allNodeDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:@"NodeDeviceCell"];

    CBPeripheral *peripheral = [self.nodeConnectionHelper.allNodeDevices objectAtIndex:indexPath.row];

    
    cell.textLabel.text = peripheral.name;
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndex = [tableView indexPathForSelectedRow];
    [tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral *peripheral = [self.nodeConnectionHelper.allNodeDevices objectAtIndex:indexPath.row];
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc]init];
    [userDictionary setObject:peripheral forKey:@"connectedPeripheral"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"peripheral" object:nil userInfo:userDictionary];
    
}



@end

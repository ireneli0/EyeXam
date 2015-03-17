//
//  DatabaseInstance.m
//  EyeXam
//
//  Created by Xinyi on 2015-03-16.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "DatabaseInstance.h"
#import "NewUserInformationViewController.h"

static DatabaseInstance *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DatabaseInstance

+(DatabaseInstance*)getsharedInstance{
    if (!sharedInstance){
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

-(BOOL)createUsers{
    BOOL isSuccess = YES;
    
    return isSuccess;
}

-(BOOL)createRecords{
    BOOL isSuccess = YES;
    
    return isSuccess;
}

-(BOOL)updateRecords{
    BOOL isSuccess = YES;
    
    return isSuccess;
}

-(void)selectUsers{
    
}

-(void)selectRecords{
    
}


@end

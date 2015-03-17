//
//  DatabaseInstance.h
//  EyeXam
//
//  Created by Xinyi on 2015-03-16.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseInstance : NSObject{
    NSString *documentPath;
}

+(DatabaseInstance *)getSharedInstance;

-(BOOL)createTableUsers;
-(BOOL)createTableRecords;
-(BOOL) addNewUser:(NSString *) tableName
           withName:(NSString *) user
        withEyetype:(NSString *) eyesightType;

-(BOOL)addNewRecords;
-(void)getAllUsers;
-(void)getAllRecordsForSelectedUser;
-(void)getNakedEyeRecordsForSelectedUser;
-(void)getWithGlassesRecordsForSelectedUser;


@end

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

-(BOOL)createTables;
-(BOOL) addNewUser:(NSString *) tableName
           withName:(NSString *) user
       withGlasses:(NSString *) wearglasses
        withEyetype:(NSString *) eyesightType;

-(BOOL)addNewRecords:(NSString *)tableName
            withName:(NSString *)user
       withtestMeter:(NSString *)testMeters
         withGlasses:(NSString *)wearGlasses
   withlefteyeResult:(NSString *)lefteyeResult
  withrighteyeResult:(NSString *)righteyeResult
            withTime:(NSString *)currenttime;

-(NSArray *)getAllUsers;
-(NSArray *)getAllRecordsForSelectedUser:(NSString *)currentUser;
-(NSArray *)getNakedEyeRecordsForSelectedUser:(NSString *)currentUser;
-(NSArray *)getWithGlassesRecordsForSelectedUser:(NSString *)currentUser;
-(BOOL)deleteSelectedUser:(NSString *)selectedUser;


@end

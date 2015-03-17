//
//  DatabaseInstance.m
//  EyeXam
//
//  Created by Xinyi on 2015-03-16.
//  Copyright (c) 2015 University of Toronro. All rights reserved.
//

#import "DatabaseInstance.h"
#import "NewUserInformationViewController.h"
#import "userInfo.h"
#import "allRecords.h"

static DatabaseInstance *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DatabaseInstance

+(DatabaseInstance*)getSharedInstance{
    if (!sharedInstance){
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

-(BOOL)createTables{
    BOOL isSuccess = YES;
    char *errMsg;
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"EyeXam.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //create database if it does not exist
    if ([filemgr fileExistsAtPath: documentPath] == NO){
      if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
          const char *createUsers_sql = "CREATE TABLE IF NOT EXISTS Users(userName TEXT,wearGlasses TEXT,eyesightType TEXT,PRIMARY KEY(userName))";
          
           if(sqlite3_exec(database,createUsers_sql,NULL,NULL,&errMsg)!=SQLITE_OK){
               isSuccess = NO;
               NSLog(@"Failed to create table Users");
            }
          
          const char *createRecords_sql = "CREATE TABLE IF NOT EXISTS Records(userName TEXT,testMeters TEXT,wearGlasses TEXT,lefteyeResult FLOAT,righteyeResult FLOAT,testTime TEXT,PRIMARY KEY(userName,testTime))";
          
          if(sqlite3_exec(database,createRecords_sql,NULL,NULL,&errMsg)!=SQLITE_OK){
              isSuccess = NO;
              NSLog(@"Failed to create table Records");
          }

          sqlite3_close(database);
          return isSuccess;
          
      }
      else{
        isSuccess = NO;
        NSAssert(0,@"Fail to open database");
      }
    }
    return isSuccess;
}



-(BOOL) addNewUser:(NSString *) tableName
         withName:(NSString *) user
       withGlasses:(NSString *) wearglasses
         withEyetype:(NSString *) eyesightType
{
     BOOL isSuccess = FALSE;

     if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
        NSString *insert_userssql = [NSString stringWithFormat:
                                  @"INSERT INTO '%@'(userName,wearglasses,eyesightType) VALUES (\"%@\",\"%@\",\"%@\")",tableName,user,wearglasses,eyesightType];
        const char *insert_users = [insert_userssql UTF8String];
         
        sqlite3_prepare_v2(database, insert_users, -1, &statement, NULL);

         if (sqlite3_step(statement) == SQLITE_DONE){
             isSuccess = TRUE;
         }
         else{
             if (sqlite3_prepare_v2(database, insert_users, -1, &statement, NULL) != SQLITE_DONE) {
                 NSLog(@"insert failed: %s", sqlite3_errmsg(database));}
         }
         sqlite3_finalize(statement);
    }
    return isSuccess;
}


-(BOOL)addNewRecords:(NSString *)tableName
            withName:(NSString *)user
       withtestMeter:(NSString *)testMeters
         withGlasses:(NSString *)wearGlasses
   withlefteyeResult:(NSString *)lefteyeResult
  withrighteyeResult:(NSString *)righteyeResult
            withTime:(NSString *)currenttime
{
    BOOL isSuccess = FALSE;
    
    if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
        NSString *insert_Recordssql = [NSString stringWithFormat:
                                     @"INSERT INTO '%@'(userName,testMeters,wearGlasses,lefteyeResult,righteyeResult,testTime) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",tableName,user,testMeters,wearGlasses,lefteyeResult,righteyeResult,currenttime];
        const char *insert_records = [insert_Recordssql UTF8String];
        
        sqlite3_prepare_v2(database, insert_records, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE){
            isSuccess = TRUE;
        }
        else{
            if (sqlite3_prepare_v2(database, insert_records, -1, &statement, NULL) != SQLITE_DONE) {
                NSLog(@"insert failed: %s", sqlite3_errmsg(database));}
        }
        sqlite3_finalize(statement);
    }
    return isSuccess;
}

-(NSArray *)getAllUsers{
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"EyeXam.db"]];
    const char *dbpath = [documentPath UTF8String];
    
    //get users' information
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *getUsers_sql = [NSString stringWithFormat:
                              @"select * from Users"];
        const char *getUsers_stmt = [getUsers_sql UTF8String];
        
        NSMutableArray *usersArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, getUsers_stmt, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW){
                char *user = (char *) sqlite3_column_text(statement, 0);
                char *Glasses = (char *) sqlite3_column_text(statement, 1);
                char *eyeType = (char *) sqlite3_column_text(statement, 2);
                
                NSString *userName = [[NSString alloc] initWithUTF8String:user];
                NSString *wearGlasses = [[NSString alloc] initWithUTF8String:Glasses];
                NSString *eyesightType = [[NSString alloc] initWithUTF8String:eyeType];
                
                userInfo *info = [[userInfo alloc] init];
                info.userName = userName;
                info.wearGlasses = wearGlasses;
                info.eyesightType = eyesightType;
                
                [usersArray addObject:info];
                
            }
            sqlite3_reset(statement);
        }
        return usersArray;
    }
    return nil;

}

-(NSArray *)getAllRecordsForSelectedUser:(NSString *)currentUser{
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"EyeXam.db"]];
    const char *dbpath = [documentPath UTF8String];
    
    //get All Records
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *getRecords_sql = [NSString stringWithFormat:
                                  @"select * from Records where userName='%@'",currentUser];
        const char *getRecords_stmt = [getRecords_sql UTF8String];
        
        NSMutableArray *allRecordsArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, getRecords_stmt, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW){
                char *user = (char *) sqlite3_column_text(statement, 0);
                char *meters = (char *)sqlite3_column_text(statement,1);
                char *Glasses = (char *) sqlite3_column_text(statement, 2);
                char *lefteye = (char *)sqlite3_column_text(statement,3);
                char *righteye = (char *)sqlite3_column_text(statement,4);
                char *time = (char *)sqlite3_column_text(statement,5);
                
                NSString *userName = [[NSString alloc] initWithUTF8String:user];
                NSString *testMeters =[[NSString alloc] initWithUTF8String:meters];
                NSString *wearGlasses = [[NSString alloc] initWithUTF8String:Glasses];
                NSString *lefteyeResult = [[NSString alloc] initWithUTF8String:lefteye];
                NSString *righteyeResult = [[NSString alloc] initWithUTF8String:righteye];
                NSString *currentTime =[[NSString alloc] initWithUTF8String:time];
                
                allRecords *records = [[allRecords alloc] init];
                records.userName = userName;
                records.testMeters = testMeters;
                records.wearGlasses = wearGlasses;
                records.lefteyeResult = lefteyeResult;
                records.righteyeResult = righteyeResult;
                records.currentTime = currentTime;
                [allRecordsArray addObject:records];
                
            }
            sqlite3_reset(statement);
        }
        return allRecordsArray;
    }
    return nil;

}

-(NSArray *)getNakedEyeRecordsForSelectedUser:(NSString *)currentUser{
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"EyeXam.db"]];
    const char *dbpath = [documentPath UTF8String];
    
    //get All Records
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *getRecords_sql = [NSString stringWithFormat:
                                    @"select * from Records where userName='%@'and wearGlasses='Naked eye'",currentUser];
        const char *getRecords_stmt = [getRecords_sql UTF8String];
        
        NSMutableArray *nakedeyeRecordsArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, getRecords_stmt, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW){
                char *user = (char *) sqlite3_column_text(statement, 0);
                char *meters = (char *)sqlite3_column_text(statement,1);
                char *Glasses = (char *) sqlite3_column_text(statement, 2);
                char *lefteye = (char *)sqlite3_column_text(statement,3);
                char *righteye = (char *)sqlite3_column_text(statement,4);
                char *time = (char *)sqlite3_column_text(statement,5);
                
                NSString *userName = [[NSString alloc] initWithUTF8String:user];
                NSString *testMeters =[[NSString alloc] initWithUTF8String:meters];
                NSString *wearGlasses = [[NSString alloc] initWithUTF8String:Glasses];
                NSString *lefteyeResult = [[NSString alloc] initWithUTF8String:lefteye];
                NSString *righteyeResult = [[NSString alloc] initWithUTF8String:righteye];
                NSString *currentTime =[[NSString alloc] initWithUTF8String:time];
                
                allRecords *records = [[allRecords alloc] init];
                records.userName = userName;
                records.testMeters = testMeters;
                records.wearGlasses = wearGlasses;
                records.lefteyeResult = lefteyeResult;
                records.righteyeResult = righteyeResult;
                records.currentTime = currentTime;
                [nakedeyeRecordsArray addObject:records];
                
            }
            sqlite3_reset(statement);
        }
        return nakedeyeRecordsArray;
    }
    return nil;

}

-(NSArray *)getWithGlassesRecordsForSelectedUser:(NSString *)currentUser{
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"EyeXam.db"]];
    const char *dbpath = [documentPath UTF8String];
    
    //get All Records
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *getRecords_sql = [NSString stringWithFormat:
                                    @"select * from Records where userName='%@'and wearGlasses='With glasses'",currentUser];
        const char *getRecords_stmt = [getRecords_sql UTF8String];
        
        NSMutableArray *withglassesRecordsArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, getRecords_stmt, -1, &statement, NULL) == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW){
                char *user = (char *) sqlite3_column_text(statement, 0);
                char *meters = (char *)sqlite3_column_text(statement,1);
                char *Glasses = (char *) sqlite3_column_text(statement, 2);
                char *lefteye = (char *)sqlite3_column_text(statement,3);
                char *righteye = (char *)sqlite3_column_text(statement,4);
                char *time = (char *)sqlite3_column_text(statement,5);
                
                NSString *userName = [[NSString alloc] initWithUTF8String:user];
                NSString *testMeters =[[NSString alloc] initWithUTF8String:meters];
                NSString *wearGlasses = [[NSString alloc] initWithUTF8String:Glasses];
                NSString *lefteyeResult = [[NSString alloc] initWithUTF8String:lefteye];
                NSString *righteyeResult = [[NSString alloc] initWithUTF8String:righteye];
                NSString *currentTime =[[NSString alloc] initWithUTF8String:time];
                
                allRecords *records = [[allRecords alloc] init];
                records.userName = userName;
                records.testMeters = testMeters;
                records.wearGlasses = wearGlasses;
                records.lefteyeResult = lefteyeResult;
                records.righteyeResult = righteyeResult;
                records.currentTime = currentTime;
                [withglassesRecordsArray addObject:records];
                
            }
            sqlite3_reset(statement);
        }
        return withglassesRecordsArray;
    }
    return nil;

}

-(BOOL)deleteSelectedUser:(NSString *)selectedUser
{
    BOOL isSuccess = FALSE;
    
//    //database initialization
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    documentPath = [[NSString alloc] initWithString:
//                    [documentsDirectory stringByAppendingPathComponent: @"EyeXam.db"]];
    
    if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
        NSString *delete_Userssql = [NSString stringWithFormat:
                                       @"DELETE * FROM Users WHERE userName = '%@'",selectedUser];
        const char *delete_selectedUser = [delete_Userssql UTF8String];
        
        sqlite3_prepare_v2(database, delete_selectedUser, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE){
            isSuccess = TRUE;
        }
        else{
            if (sqlite3_prepare_v2(database, delete_selectedUser, -1, &statement, NULL) != SQLITE_DONE) {
                NSLog(@"delete failed: %s", sqlite3_errmsg(database));}
        }
        sqlite3_finalize(statement);
    }
    
    
    return isSuccess;
}


@end

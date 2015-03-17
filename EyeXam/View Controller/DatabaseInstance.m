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

+(DatabaseInstance*)getSharedInstance{
    if (!sharedInstance){
        sharedInstance = [[super allocWithZone:NULL]init];
        
    }
    return sharedInstance;
}

-(BOOL)createUsers{
    BOOL isSuccess = YES;
    char *errMsg;
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"Users.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //create table if it does not exist
    if ([filemgr fileExistsAtPath: documentPath] == NO){
      if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
          const char *create_sql = "CREATE TABLE IF NOT EXISTS Users(userName TEXT,eyesightType TEXT,PRIMARY KEY(userName))";
          
           if(sqlite3_exec(database,create_sql,NULL,NULL,&errMsg)!=SQLITE_OK){
               isSuccess = NO;
               NSLog(@"Failed to create table");
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


-(BOOL)createRecords{
    BOOL isSuccess = YES;
    char *errMsg;
    //database initialization
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentPath = [[NSString alloc] initWithString:
                    [documentsDirectory stringByAppendingPathComponent: @"Records.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //create table if it does not exist
    if ([filemgr fileExistsAtPath: documentPath] == NO){
        if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
            const char *create_sql = "CREATE TABLE IF NOT EXISTS Records(userName TEXT,meters TEXT,wearGlasses TEXT,lefteyeResult TEXT,righteyeResult TEXT,date TEXT,PRIMARY KEY(userName,date))";
            
            if(sqlite3_exec(database,create_sql,NULL,NULL,&errMsg)!=SQLITE_OK){
                isSuccess = NO;
                NSLog(@"Failed to create table");
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


-(BOOL) updateUsers:(NSString *) tableName
         withName:(NSString *) user
         withEyetype:(NSString *) eyesightType
{
     BOOL isSuccess = FALSE;

     if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
        NSString *insert_userssql = [NSString stringWithFormat:
                                  @"INSERT INTO '%@'(userName,eyesightType) VALUES (\"%@\",\"%@\")",tableName,user,eyesightType];
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


-(BOOL)updateRecords{
    BOOL isSuccess = YES;
    
      if(sqlite3_open([documentPath UTF8String], &database)==SQLITE_OK){
          
          
          
      }
    
    
    return isSuccess;
}

-(void)selectUsers{
    
}

-(void)selectRecords{
    
}


@end

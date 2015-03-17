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

-(BOOL)createUsers;
-(BOOL)createRecords;
-(BOOL) updateUsers:(NSString *) tableName
           withName:(NSString *) user
        withEyetype:(NSString *) eyesightType;
-(BOOL)updateRecords;
-(void)selectUsers;
-(void)selectRecords;


@end

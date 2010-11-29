//
//  PXSQLiteObject.h
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>

//This is a fun litle class that makes the SQLite saving easier

typedef enum{
	SQL_NULL = 0, //Stuck because NULL is a reserved word in C
	SQL_INTEGER = 1,
	SQL_REAL = 2,
	SQL_TEXT = 3,
	SQL_BLOB = 4
} SQLITE_TYPE;

@interface PXSQLiteObject : NSObject {
@private
    
}

+(NSDictionary *)getProperties;
+(NSString *)getName;
+(NSArray *)getParents;

@end

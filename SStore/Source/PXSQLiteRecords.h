//
//  PXSQLiteRecords.h
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "PXSQLiteObject.h"

@interface PXSQLiteRecords : NSObject {
@private
    sqlite3 *db;
	NSString *password;
	BOOL newDB;
}
@property (readwrite, nonatomic) sqlite3 *db;
@property (readwrite, nonatomic, retain) NSString *password;

-(id)initDatabaseAtLocation:(NSString *)dbLocation;
-(id)initDatabaseAtLocation:(NSString *)dbLocation withPassword:(NSString *)pw;

-(void)save:(PXSQLiteObject *)object;
-(NSSet *)objectsOfType:(Class)class forKey:(NSString *)keyPath value:(id)value;

@end

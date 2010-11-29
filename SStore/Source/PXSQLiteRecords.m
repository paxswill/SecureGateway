//
//  PXSQLiteRecords.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSQLiteRecords.h"

@interface PXSQLiteRecords()

+(int)bindString:(NSString *)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
+(int)bindInt:(int)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
+(int)bindDouble:(double)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
+(int)bindData:(NSData *)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;

@end


@implementation PXSQLiteRecords

@synthesize db;
@synthesize password;

-(id)initDatabaseAtLocation:(NSString *)dbLocation{
	if((self = [self initDatabaseAtLocation:dbLocation withPassword:nil])){
		
	}
	return self;
}

-(id)initDatabaseAtLocation:(NSString *)dbLocation withPassword:(NSString *)pw{
	if((self = [super init])){
		//Open the DB
		char *errorMessage;
		int status = sqlite3_open_v2([dbLocation UTF8String], &db, (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE), NULL);
		if(status != SQLITE_OK){
			//Error in opening
			NSLog(@"Error in opening SQLite DB: %s", sqlite3_errmsg(db));
			sqlite3_close(db);
			return nil;
		}
		//Do we need encryption?
		if(pw != nil){
			//Add the encryption key
			sqlite3_stmt *cryptoStmt;
			status = sqlite3_prepare_v2(db, "PRAGMA key = '@KEY'", -1, &cryptoStmt, NULL);
			//Bind the password in
			status = [PXSQLiteRecords bindString:pw forName:@"KEY" inStatement:cryptoStmt];
			//Step until done
			do{
				status = sqlite3_step(cryptoStmt);
			}while(status != SQLITE_DONE);
			//close out the statement
			sqlite3_finalize(cryptoStmt);
		}
		
		//Turn on verbose errors
		sqlite3_extended_result_codes(db, 1);
		//Turn on Foreign key support
		status = sqlite3_exec(db, "PRAGMA foreign_keys = ON;", NULL, NULL, &errorMessage);
		//Figure out if we need to define the starting schema
		//Is this a new database, or an old one?
		//Check by retrieving the schema_version pragma. If it's 0 there's no schema
		sqlite3_stmt *versionStmt;
		//The third paramter is the length of the statement, including null terminator
		status = sqlite3_prepare_v2(db, "PRAGMA schema_version;", (sizeof(char) * 21), &versionStmt, NULL);
		int schemaVersion = 0;
		do{
			//Step the statement
			status = sqlite3_step(versionStmt);
			//Is there data?
			if(status == SQLITE_ROW){
				//It /should/ be an int
				schemaVersion = sqlite3_column_int(versionStmt, 0);
			}
		}while(status != SQLITE_DONE);
		sqlite3_finalize(versionStmt);
		//Now to check if it's a new table
		if(schemaVersion == 0){
			//New or unintialized database
			//Create the schema
			sqlite3_stmt *schemaStmt;
			status = sqlite3_prepare_v2(db, "CREATE TABLE objects(class_name TEXT, super_class TEXT);", (sizeof(char) * 60), &schemaStmt, NULL);
			//Step until done
			do{
				status = sqlite3_step(versionStmt);
			}while(status != SQLITE_DONE);
			//close out the statement
			sqlite3_finalize(schemaStmt);
		}
	}
	return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

//Private binding methods
+(int)bindString:(NSString *)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt{
	int parameterIndex = sqlite3_bind_parameter_index(stmt, [varName UTF8String]);
	//There's some magic here, so here's an explanation
	//Args 1 and 2 are simple enough, 3 is a C string, 4 is the size in bytes of the string,
	// and 5 is a special value saying that the string passed may change in the future
	// (which it does, std::string.c_str() returns an internal representation that changes)
	return sqlite3_bind_text(stmt, parameterIndex, [var UTF8String], ([var length] + 1) * sizeof(char), SQLITE_TRANSIENT);
}

+(int)bindInt:(int)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt{
	int parameterIndex = sqlite3_bind_parameter_index(stmt, [varName UTF8String]);
	return sqlite3_bind_int(stmt, parameterIndex, var);
}

+(int)bindDouble:(double)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt{
	int parameterIndex = sqlite3_bind_parameter_index(stmt, [varName UTF8String]);
	return sqlite3_bind_int(stmt, parameterIndex, var);
}

+(int)bindData:(NSData *)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt{
	int parameterIndex = sqlite3_bind_parameter_index(stmt, [varName UTF8String]);
	//There's some magic here, so here's an explanation
	//Args 1 and 2 are simple enough, 3 is a C string, 4 is the size in bytes of the string,
	// and 5 is a special value saying that the string passed may change in the future
	// (which it does, std::string.c_str() returns an internal representation that changes)
	return sqlite3_bind_blob(stmt, parameterIndex, [var bytes], [var length], SQLITE_TRANSIENT);
}

@end

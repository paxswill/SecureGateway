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
    //TODO: close out the database
    [super dealloc];
}



-(void)save:(PXSQLiteObject *)object{
	//First, is this object in the store already?
	NSArray *familyTree = [[object class] getParents];
	//Make the eusable statements
	sqlite3_stmt *checkStmt;
	sqlite3_stmt *addStmt;
	int status = sqlite3_prepare_v2(self.db, "SELECT class_name FROM objects WHERE class_name='@CLASS' AND super_class='@SUPER' LIMIT 1;", -1, &checkStmt, NULL);
	status = sqlite3_prepare_v2(self.db, "INSERT INTO objects(class_name, super_class) VALUES ('@CLASS', '@SUPER');", -1, &addStmt, NULL);
	for(int i = 0; i < ([familyTree count] - 1); ++i){
		//Check to see if the current class exists in the DB
		status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:i] forName:@"CLASS" inStatement:checkStmt];
		status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:(i + 1)] forName:@"SUPER" inStatement:checkStmt];
		//Run the query
		BOOL found = NO;
		do{
			status = sqlite3_step(checkStmt);
			found = (status == SQLITE_ROW) ? YES : NO;
		}while(status != SQLITE_DONE && !found);
		if(!found){
			//We need to insert. Bind the var names in
			status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:i] forName:@"CLASS" inStatement:addStmt];
			status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:(i + 1)] forName:@"SUPER" inStatement:addStmt];
			//Run the statement
			do{
				status = sqlite3_step(checkStmt);
			}while(status != SQLITE_DONE);
			//Should be done now
			sqlite3_reset(addStmt);
		}
		sqlite3_reset(checkStmt);
	}
	sqlite3_finalize(checkStmt);
	sqlite3_finalize(addStmt);
	
	//OK, now that it is ensured that the class structure is in the DB, we can read the object in
	//Is there a table for the Class?
	sqlite3_stmt *checkTableStmt;
	status = sqlite3_prepare_v2(self.db, "SELECT name FROM sqlite_master WHERE type='table' AND name='@CLASS' LIMIT 1;", -1, &checkTableStmt, NULL);
	status = [PXSQLiteRecords bindString:[[object class] getName] forName:@"CLASS" inStatement:checkTableStmt];
	BOOL found = NO;
	do{
		status = sqlite3_step(checkTableStmt);
		found = (status == SQLITE_ROW) ? YES : NO;
	}while(status != SQLITE_DONE && !found);
	sqlite3_finalize(checkTableStmt);
	if(!found){
		//We need to add a table for this class
		NSMutableString *tableCreate = [NSMutableString stringWithFormat:@"CREATE TABLE %@(", [[object class] getName]];
		NSDictionary *objectVars = [[[object class] getProperties] retain];
		for(NSString *colName in [objectVars allKeys]){
			[tableCreate appendFormat:@"%@ %@, ", colName, [objectVars valueForKey:colName]];
		}
		//Trim the last ', ' out
		[tableCreate deleteCharactersInRange:NSMakeRange([tableCreate length] - 2, [tableCreate length])];
		[tableCreate appendFormat:@");"];
		//Quickly run this
		status = sqlite3_exec(self.db, [tableCreate UTF8String], NULL, NULL, NULL);
		//Clean up
		[objectVars release];
	}
}

-(PXSQLiteObject *)objectForKey:(NSString *)keyPath value:(NSString *)value{
	
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

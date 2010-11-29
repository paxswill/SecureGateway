//
//  PXSQLiteRecords.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSQLiteRecords.h"

@interface PXSQLiteRecords()
//Binding convenience methods
+(int)bindString:(NSString *)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
+(int)bindInt:(int)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
+(int)bindDouble:(double)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
+(int)bindData:(NSData *)var forName:(NSString *)varName inStatement:(sqlite3_stmt *)stmt;
//Query convenience methods
-(void)runStatement:(sqlite3_stmt *)stmt;
-(BOOL)runStatementLookingForResults:(sqlite3_stmt *)stmt;
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
			status = [PXSQLiteRecords bindString:pw forName:@"@KEY" inStatement:cryptoStmt];
			//Step until done
			[self runStatement:cryptoStmt];
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
			[self runStatement:schemaStmt];
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
	//First, is this object type in the store already?
	NSArray *familyTree = [[object class] getParents];
	//Make the eusable statements
	sqlite3_stmt *checkStmt;
	sqlite3_stmt *addStmt;
	int status = sqlite3_prepare_v2(self.db, "SELECT class_name FROM objects WHERE class_name=@CLASS AND super_class=@SUPER LIMIT 1;", -1, &checkStmt, NULL);
	status = sqlite3_prepare_v2(self.db, "INSERT INTO objects(class_name, super_class) VALUES (@CLASS, @SUPER);", -1, &addStmt, NULL);
	for(int i = 0; i < ([familyTree count] - 1); ++i){
		//Check to see if the current class exists in the DB
		status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:i] forName:@"@CLASS" inStatement:checkStmt];
		status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:(i + 1)] forName:@"@SUPER" inStatement:checkStmt];
		//Run the query
		BOOL found = [self runStatementLookingForResults:checkStmt];
		if(!found){
			//We need to insert. Bind the var names in
			status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:i] forName:@"@CLASS" inStatement:addStmt];
			status = [PXSQLiteRecords bindString:[familyTree objectAtIndex:(i + 1)] forName:@"@SUPER" inStatement:addStmt];
			//Run the statement
			[self runStatement:addStmt];
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
	status = sqlite3_prepare_v2(self.db, "SELECT name FROM sqlite_master WHERE type='table' AND name=@CLASS LIMIT 1;", -1, &checkTableStmt, NULL);
	status = [PXSQLiteRecords bindString:[[object class] getName] forName:@"@CLASS" inStatement:checkTableStmt];
	BOOL found = [self runStatementLookingForResults:checkTableStmt];
	sqlite3_finalize(checkTableStmt);
	if(!found){
		//We need to add a table for this class
		NSMutableString *tableCreate = [NSMutableString stringWithFormat:@"CREATE TABLE %@(", [[object class] getName]];
		NSDictionary *objectVars = [[[object class] getProperties] retain];
		for(NSString *colName in [objectVars allKeys]){
			[tableCreate appendFormat:@"%@ %@, ", colName, [objectVars valueForKey:colName]];
		}
		//Trim the last ', ' out
		[tableCreate setString:[tableCreate substringToIndex:([tableCreate length] - 2)]];
		[tableCreate appendFormat:@");"];
		//Quickly run this
		status = sqlite3_exec(self.db, [tableCreate UTF8String], NULL, NULL, NULL);
		//Clean up
		[objectVars release];
	}
	
	//And now to actually insert the data
	//But first, check to see if we've already added it
	sqlite3_stmt *checkClassStmt;
	status = sqlite3_prepare_v2(self.db, "SELECT idNumber FROM :CLASS WHERE idNumber=@IDNUM LIMIT 1;", -1, &checkClassStmt, NULL);
	status = [PXSQLiteRecords bindString:[[object class] getName] forName:@":CLASS" inStatement:checkClassStmt];
	status = [PXSQLiteRecords bindInt:[object idNumber] forName:@"@IDNUM" inStatement:checkClassStmt];
	found = [self runStatementLookingForResults:checkClassStmt];
	sqlite3_finalize(checkClassStmt);
	//Ok, so now we get to make either an update or insert query
	sqlite3_stmt *addOrInsertStmt;
	NSDictionary *objectProperties = [[[object class] getProperties] retain];
	if(found){
		//Update
		NSMutableString *update = [NSMutableString stringWithFormat:@"UPDATE @CLASS SET "];
		//Build the update string
		for(NSString *property in [objectProperties allKeys]){
			//Update
			if([[objectProperties valueForKey:property] isEqualToString:@"TEXT"]){
				[update appendFormat:@"@%@=@%@VAL, ", property, property];
			}else if([[objectProperties valueForKey:property] isEqualToString:@"REAL"]){
				[update appendFormat:@"@%@=@%@VAL, ", property, property];
			}else if([[objectProperties valueForKey:property] isEqualToString:@"INTEGER"]){
				[update appendFormat:@"@%@=@%@VAL, ", property, property];
			}else if([[objectProperties valueForKey:property] isEqualToString:@"BLOB"]){
				[update appendFormat:@"@%@=@%@VAL, ", property, property];
			}
		}
		//Tidy up the end of the string
		[update setString:[update substringToIndex:([update length] - 2)]];;
		[update appendFormat:@" WHERE idNumber=@idNumberVAL;"];
		status = sqlite3_prepare_v2(self.db, [update UTF8String], -1, &addOrInsertStmt, NULL);
	}else{
		//Insert
		NSMutableString *insertHeader = [NSMutableString stringWithFormat:@"INSERT INTO @CLASS ("];
		NSMutableString *insertValues = [NSMutableString stringWithFormat:@") VALUES ("];
		//Build the update string
		for(NSString *property in [objectProperties allKeys]){
			//Update
			if([[objectProperties valueForKey:property] isEqualToString:@"TEXT"]){
				[insertHeader appendFormat:@"@%@, ", property];
				[insertValues appendFormat:@"@%@VAL, ", property];
			}else if([[objectProperties valueForKey:property] isEqualToString:@"REAL"]){
				[insertHeader appendFormat:@"@%@, ", property];
				[insertValues appendFormat:@"@%@VAL, ", property];
			}else if([[objectProperties valueForKey:property] isEqualToString:@"INTEGER"]){
				[insertHeader appendFormat:@"@%@, ", property];
				[insertValues appendFormat:@"@%@VAL, ", property];
			}else if([[objectProperties valueForKey:property] isEqualToString:@"BLOB"]){
				[insertHeader appendFormat:@"@%@, ", property];
				[insertValues appendFormat:@"@%@VAL, ", property];
			}
		}
		//Clean the ends up
		[insertHeader setString:[insertHeader substringToIndex:([insertHeader length] - 2)]];
		[insertValues setString:[insertValues substringToIndex:([insertValues length] - 2)]];
		[insertHeader appendFormat:@"%@);", insertValues];
		status = sqlite3_prepare_v2(self.db, [insertHeader UTF8String], -1, &addOrInsertStmt, NULL);
	}
	//And now we bind everything
	for(NSString *property in [objectProperties allKeys]){
		if([[objectProperties valueForKey:property] isEqualToString:@"TEXT"]){
			[PXSQLiteRecords bindString:property forName:[NSString stringWithFormat:@"@%@", property] inStatement:addOrInsertStmt];
			[PXSQLiteRecords bindString:[objectProperties valueForKey:property] forName:[NSString stringWithFormat:@"@%@VAL", property] inStatement:addOrInsertStmt];
		}else if([[objectProperties valueForKey:property] isEqualToString:@"REAL"]){
			[PXSQLiteRecords bindString:property forName:[NSString stringWithFormat:@"@%@", property] inStatement:addOrInsertStmt];
			[PXSQLiteRecords bindDouble:[[objectProperties valueForKey:property] doubleValue] forName:[NSString stringWithFormat:@"@%@VAL", property] inStatement:addOrInsertStmt];
		}else if([[objectProperties valueForKey:property] isEqualToString:@"INTEGER"]){
			[PXSQLiteRecords bindString:property forName:[NSString stringWithFormat:@"@%@", property] inStatement:addOrInsertStmt];
			[PXSQLiteRecords bindInt:[[objectProperties valueForKey:property] intValue] forName:[NSString stringWithFormat:@"@%@VAL", property] inStatement:addOrInsertStmt];
		}else if([[objectProperties valueForKey:property] isEqualToString:@"BLOB"]){
			[PXSQLiteRecords bindString:property forName:[NSString stringWithFormat:@"@%@", property] inStatement:addOrInsertStmt];
			[PXSQLiteRecords bindData:[NSKeyedArchiver archivedDataWithRootObject:[objectProperties valueForKey:property]] forName:[NSString stringWithFormat:@"@%@VAL", property] inStatement:addOrInsertStmt];
		}
	}
	//And finally, we run it
	[self runStatement:addOrInsertStmt];
	sqlite3_finalize(addOrInsertStmt);
	[objectProperties release];
}

-(NSSet *)objectsOfType:(Class)class forKey:(NSString *)keyPath value:(id)value{
	//First, what type are we looking at here
	objc_property_t property = class_getProperty(class, [keyPath UTF8String]);
	NSString *sqlType = [PXSQLiteObject typeForObjCProperty:property];
	NSDictionary *properties = [class getProperties];
	//The Set to return
	NSMutableSet *returnSet = [[NSMutableSet alloc] init];
	//Build a Select query for this type
	NSArray *keys = [properties allKeys];
	NSMutableString *select = [[NSMutableString alloc] initWithString:@"SELECT "];
	for(NSString *prop in keys){
		[select appendFormat:@"%@, ", prop]; 
	}
	[select setString:[select substringToIndex:([select length] - 2)]];
	[select appendString:@" FROM @CLASS WHERE @KEYPATH="];
	if([sqlType isEqualToString:@"TEXT"]){
		[select appendString:@"'@VALUE';"];
	}else{
		//something other than text
		[select appendString:@"@VALUE;"];
	}
	//Build the query
	sqlite3_stmt *keyStmt;
	int status = sqlite3_prepare_v2(self.db, [select UTF8String], -1, &keyStmt, NULL);
	//Bind the vars
	[PXSQLiteRecords bindString:[class getName] forName:@"@CLASS" inStatement:keyStmt];
	[PXSQLiteRecords bindString:keyPath forName:@"@KEYPATH" inStatement:keyStmt];
	if([sqlType isEqualToString:@"TEXT"]){
		[PXSQLiteRecords bindString:value forName:@"@VALUE" inStatement:keyStmt];
	}else if([sqlType isEqualToString:@"REAL"]){
		[PXSQLiteRecords bindDouble:[value doubleValue] forName:@"@VALUE" inStatement:keyStmt];
	}else if([sqlType isEqualToString:@"INTEGER"]){
		[PXSQLiteRecords bindInt:[value intValue] forName:@"@VALUE" inStatement:keyStmt];
	}else if([sqlType isEqualToString:@"BLOB"]){
		[PXSQLiteRecords bindData:[NSKeyedArchiver archivedDataWithRootObject:value] forName:@"@VALUE" inStatement:keyStmt];
	}
	//Run the query
	do{
		status = sqlite3_step(keyStmt);
		if(status == SQLITE_ROW){
			//Instantiate the class
			id someClassInstance = class_createInstance(class, 0);
			//Retrieve the column data
			for(int i = 0; i < [keys count]; ++i){
				NSString *key = [keys objectAtIndex:i];
				objc_property_t keyProp = class_getProperty(class, [key UTF8String]);
				
				//Now to branch based on what the types of this property is
				if([[PXSQLiteObject typeForObjCProperty:keyProp] isEqualToString:@"TEXT"]){
					[someClassInstance setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(keyStmt, i)] forKeyPath:key];
				}else if([[PXSQLiteObject typeForObjCProperty:keyProp] isEqualToString:@"REAL"]){
					[someClassInstance setValue:[NSNumber numberWithDouble:sqlite3_column_double(keyStmt, i)] forKeyPath:key];
				}else if([[PXSQLiteObject typeForObjCProperty:keyProp] isEqualToString:@"INTEGER"]){
					[someClassInstance setValue:[NSNumber numberWithInt:sqlite3_column_int(keyStmt, i)] forKeyPath:key];
				}else if([[PXSQLiteObject typeForObjCProperty:keyProp] isEqualToString:@"BLOB"]){
					[someClassInstance setValue:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithBytes:sqlite3_column_blob(keyStmt, i) length:sqlite3_column_bytes(keyStmt, i)]] forKeyPath:key];
				}
			}
			//Now that the object is made, put it in the Set
			[returnSet addObject:someClassInstance];
		}
	}while(status != SQLITE_DONE);
	sqlite3_finalize(keyStmt);
	return [returnSet autorelease];
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

-(void)runStatement:(sqlite3_stmt *)stmt{
	int status;
	do{
		status = sqlite3_step(stmt);
	}while(status != SQLITE_DONE);
}

-(BOOL)runStatementLookingForResults:(sqlite3_stmt *)stmt{
	int status;
	BOOL found = NO;
	do{
		status = sqlite3_step(stmt);
		found = (status == SQLITE_ROW) ? YES : NO;
	}while(status != SQLITE_DONE && !found);
	return found;
}

@end

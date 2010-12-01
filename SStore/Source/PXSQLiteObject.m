//
//  PXSQLiteObject.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSQLiteObject.h"


@implementation PXSQLiteObject

@synthesize idNumber;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

+(NSDictionary *)getProperties{
	//This will hold all of the properties
	NSMutableDictionary *propertyList = [[NSMutableDictionary alloc] init];
	//Start with our class
	Class currentClass = [self class];
	//Now iterate up through the superclasses
	do{
		//Get a list of the properties
		objc_property_t *properties;
		unsigned int propertyCount;
		properties = class_copyPropertyList(currentClass, &propertyCount);
		//Iterate through the properties
		for(int i = 0; i < propertyCount; ++i){
			NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(properties[i])];
			[propertyList setValue:[PXSQLiteObject typeForObjCProperty:properties[i]] forKey:propertyName];
			[propertyName release];
		}
		//Go up a class
		currentClass = class_getSuperclass(currentClass);
	}while(currentClass != [NSObject class]);
	return [propertyList autorelease];
}

+(NSString*)getName{
	return [NSString stringWithUTF8String:class_getName([self class])];
}

+(NSArray *)getParents{
	NSMutableArray *parents = [[NSMutableArray alloc] init];
	Class currentClass = [self class];
	do{
		[parents addObject:[NSString stringWithUTF8String:class_getName(currentClass)]];
		currentClass = class_getSuperclass(currentClass);
	}while(currentClass != [NSObject class]);
	[parents addObject:@"NSObject"];
	return [parents autorelease];
}

+(NSString *)typeForSQLiteType:(SQLITE_TYPE)t{
	switch(t){
		case SQL_INTEGER:
			return @"INTEGER";
		case SQL_REAL:
			return @"REAL";
		case SQL_TEXT:
			return @"TEXT";
		case SQL_BLOB:
			return @"BLOB";
		default:
		case SQL_NULL:
			return @"NULL";
	}
}

+(SQLITE_TYPE)sqlTypeForEncode:(char *)encode{
	SQLITE_TYPE type;
	switch(encode[0]){
		case 'c':
		case 'C':
		case '*':
			//chars and strings
			type = SQL_TEXT;
			break;
		case 'i':
		case 's':
		case 'l':
		case 'q':
		case 'I':
		case 'S':
		case 'L':
		case 'Q':
		case 'B':
			//Various integers and BOOL
			type = SQL_INTEGER;
			break;
		case 'f':
		case 'd':
			//floating point numbers
			type = SQL_REAL;
			break;

		case '@':
			//An object
			//In most cases, store as a blob, but in other cases store more suited data
			
			type = SQL_BLOB;
			break;
		case 'v':
		case '#':
		case ':':
		case '[':
		case '{':
		case '(':
		case 'b':
		case '^':
		case '?':
		default:
			//Unknown/We don't care
			type = SQL_NULL;
			break;
	}
	return type;
}

+(NSString *)typeForObjCProperty:(objc_property_t)prop{
	char *encode = [PXSQLiteObject encodeForObjCProperty:prop];
	SQLITE_TYPE type = [PXSQLiteObject sqlTypeForEncode:encode];
	return [PXSQLiteObject typeForSQLiteType:type];
}

+(BOOL)propertyTypeIsChild:(objc_property_t)prop{
	//We may have one of our special child objects. For them, 
	//the type is SQL_TEXT, as we store id numbers
	//The structure should be in the form of {"ClassName"=fields}
	NSString *encodeString = [NSString stringWithUTF8String:[PXSQLiteObject encodeForObjCProperty:prop]];
	//Trim the ends off
	encodeString = [encodeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
	//Cut everythin after the eqlas sign off
	encodeString = [encodeString substringToIndex:[encodeString rangeOfString:@"="].location];
	//So now we should have the class name. Let's create one
	Class aClass = objc_getClass([encodeString UTF8String]);
	id anInstance = class_createInstance(aClass, 0);
	return [anInstance isKindOfClass:objc_getClass("PXSQLiteObject")];
}

+(char *)encodeForObjCProperty:(objc_property_t)prop{
	//For now, we're just including the Obj-C type
	NSString *propertyAttributes = [[NSString alloc] initWithUTF8String:property_getAttributes(prop)];
	//The properties are a bit hairy, the format is described here:
	//http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html%23//apple_ref/doc/uid/TP40008048-CH101
	NSArray *components = [[propertyAttributes componentsSeparatedByString:@","] retain];
	char * toReturn = (char *)[[[components objectAtIndex:0] substringFromIndex:1] UTF8String];
	[components release];
	return toReturn;
}

@end

//
//  PXSQLiteObject.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSQLiteObject.h"


@implementation PXSQLiteObject

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
	//Ok, first get a copy of the Class variable
	Class thisClass = [self class];
	//Now get a list of the properties
	objc_property_t *properties;
	unsigned int propertyCount;
	properties = class_copyPropertyList(thisClass, &propertyCount);
	//Now iterate through the properties
	NSMutableDictionary *propertyList = [[NSMutableDictionary alloc] initWithCapacity:propertyCount];
	for(int i = 0; i < propertyCount; ++i){
		NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(properties[i])];
		//The properties are a bit hairy, the format is described here:
		//http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html%23//apple_ref/doc/uid/TP40008048-CH101
		//For now, we're just including the Obj-C type
		NSString *propertyAttributes = [[NSString alloc] initWithUTF8String:property_getAttributes(properties[i])];
		NSArray *components = [[propertyAttributes componentsSeparatedByString:@","] retain];
		//At index one, we should have T, followed by the @encoded'd type
		SQLITE_TYPE type;
		switch([[components objectAtIndex:0] characterAtIndex:1]){
			case 'c':
			case 'C':
			case '*':
				//chars
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
				//Various integers
				type = SQL_INTEGER;
				break;
			case 'f':
			case 'd':
				//floating point numbers
				type = SQL_REAL;
				break;
			case 'B':
				//Booleans are stored as ints
				break;
			case '@':
				//An object
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
		[components release];
		[propertyList setValue:[NSNumber numberWithInt:(int)type] forKey:propertyName];
		[propertyName release];
	}
	return [propertyList autorelease];
}

@end

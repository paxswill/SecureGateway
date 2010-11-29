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
			[components release];
			[propertyList setValue:[NSNumber numberWithInt:(int)type] forKey:propertyName];
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
	}while(currentClass != [NSObject class]);
	[parents addObject:@"NSObject"];
	return [parents autorelease];
}

@end

//
//  PXDocument.h
//  SStore
//
//  Created by Will Ross on 11/30/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXSQLiteObject.h"
#import "PXFaculty.h"

@interface PXDocument : PXSQLiteObject {
@private
	PXFaculty *owner;
    NSMutableSet *allowedPersons;
	NSMutableSet *allowedClasses;
	NSData *fileData;
}
@property (readwrite, nonatomic, retain) PXFaculty *owner;
@property (readwrite, nonatomic, retain) NSMutableSet *allowedPersons;
@property (readwrite, nonatomic, retain) NSMutableSet *allowedClasses;
@property (readwrite, nonatomic, retain) NSData *fileData;

@end

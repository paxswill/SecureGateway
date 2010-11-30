//
//  PXCourse.h
//  SStore
//
//  Created by Will Ross on 11/30/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXSQLiteObject.h"
#import "PXFaculty.h"

@interface PXCourse : PXSQLiteObject {
@private
	PXFaculty *instructor;
	NSSet *students
	
}

@end

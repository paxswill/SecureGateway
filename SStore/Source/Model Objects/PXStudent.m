//
//  PXStudent.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import "PXStudent.h"


@implementation PXStudent
@dynamic enrolledCourses;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (PXCourse *)enrolledCourses {
    id tmpObject;
    
    [self willAccessValueForKey:@"enrolledCourses"];
    tmpObject = [self primitiveEnrolledCourses];
    [self didAccessValueForKey:@"enrolledCourses"];
    
    return tmpObject;
}

- (void)setEnrolledCourses:(PXCourse *)value {
    [self willChangeValueForKey:@"enrolledCourses"];
    [self setPrimitiveEnrolledCourses:value];
    [self didChangeValueForKey:@"enrolledCourses"];
}

- (BOOL)validateEnrolledCourses:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

#endif

@end

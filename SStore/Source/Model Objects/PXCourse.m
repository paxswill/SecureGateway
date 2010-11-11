//
//  PXCourse.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import "PXCourse.h"


@implementation PXCourse
@dynamic name;
@dynamic idNumber;
@dynamic instructor;
@dynamic enrolledStudents;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (NSString *)name {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"name"];
    tmpValue = [self primitiveName];
    [self didAccessValueForKey:@"name"];
    
    return tmpValue;
}

- (void)setName:(NSString *)value {
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:value];
    [self didChangeValueForKey:@"name"];
}

- (BOOL)validateName:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)idNumber {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"idNumber"];
    tmpValue = [self primitiveIdNumber];
    [self didAccessValueForKey:@"idNumber"];
    
    return tmpValue;
}

- (void)setIdNumber:(NSNumber *)value {
    [self willChangeValueForKey:@"idNumber"];
    [self setPrimitiveIdNumber:value];
    [self didChangeValueForKey:@"idNumber"];
}

- (BOOL)validateIdNumber:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (PXFaculty *)instructor {
    id tmpObject;
    
    [self willAccessValueForKey:@"instructor"];
    tmpObject = [self primitiveInstructor];
    [self didAccessValueForKey:@"instructor"];
    
    return tmpObject;
}

- (void)setInstructor:(PXFaculty *)value {
    [self willChangeValueForKey:@"instructor"];
    [self setPrimitiveInstructor:value];
    [self didChangeValueForKey:@"instructor"];
}

- (BOOL)validateInstructor:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}


- (void)addEnrolledStudentsObject:(PXStudent *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveEnrolledStudents] addObject:value];
    [self didChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeEnrolledStudentsObject:(PXStudent *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveEnrolledStudents] removeObject:value];
    [self didChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addEnrolledStudents:(NSSet *)value {    
    [self willChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveEnrolledStudents] unionSet:value];
    [self didChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEnrolledStudents:(NSSet *)value {
    [self willChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveEnrolledStudents] minusSet:value];
    [self didChangeValueForKey:@"enrolledStudents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif

@end

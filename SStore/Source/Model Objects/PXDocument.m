//
//  PXDocument.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import "PXDocument.h"


@implementation PXDocument
@dynamic documentData;
@dynamic documentPath;
@dynamic name;
@dynamic owner;
@dynamic allowedPersons;
@dynamic allowedCourses;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (NSData *)documentData {
    NSData * tmpValue;
    
    [self willAccessValueForKey:@"documentData"];
    tmpValue = [self primitiveDocumentData];
    [self didAccessValueForKey:@"documentData"];
    
    return tmpValue;
}

- (void)setDocumentData:(NSData *)value {
    [self willChangeValueForKey:@"documentData"];
    [self setPrimitiveDocumentData:value];
    [self didChangeValueForKey:@"documentData"];
}

- (BOOL)validateDocumentData:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)documentPath {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"documentPath"];
    tmpValue = [self primitiveDocumentPath];
    [self didAccessValueForKey:@"documentPath"];
    
    return tmpValue;
}

- (void)setDocumentPath:(NSString *)value {
    [self willChangeValueForKey:@"documentPath"];
    [self setPrimitiveDocumentPath:value];
    [self didChangeValueForKey:@"documentPath"];
}

- (BOOL)validateDocumentPath:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

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

- (PXFaculty *)owner {
    id tmpObject;
    
    [self willAccessValueForKey:@"owner"];
    tmpObject = [self primitiveOwner];
    [self didAccessValueForKey:@"owner"];
    
    return tmpObject;
}

- (void)setOwner:(PXFaculty *)value {
    [self willChangeValueForKey:@"owner"];
    [self setPrimitiveOwner:value];
    [self didChangeValueForKey:@"owner"];
}

- (BOOL)validateOwner:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}


- (void)addAllowedPersonsObject:(PXPerson *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveAllowedPersons] addObject:value];
    [self didChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeAllowedPersonsObject:(PXPerson *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveAllowedPersons] removeObject:value];
    [self didChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addAllowedPersons:(NSSet *)value {    
    [self willChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveAllowedPersons] unionSet:value];
    [self didChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAllowedPersons:(NSSet *)value {
    [self willChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveAllowedPersons] minusSet:value];
    [self didChangeValueForKey:@"allowedPersons" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addAllowedCoursesObject:(PXCourse *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveAllowedCourses] addObject:value];
    [self didChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeAllowedCoursesObject:(PXCourse *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveAllowedCourses] removeObject:value];
    [self didChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addAllowedCourses:(NSSet *)value {    
    [self willChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveAllowedCourses] unionSet:value];
    [self didChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAllowedCourses:(NSSet *)value {
    [self willChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveAllowedCourses] minusSet:value];
    [self didChangeValueForKey:@"allowedCourses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif

@end

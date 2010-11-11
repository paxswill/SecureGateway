//
//  PXFaculty.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import "PXFaculty.h"


@implementation PXFaculty
@dynamic coursesTaught;
@dynamic documentsOwned;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (void)addCoursesTaughtObject:(PXCourse *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveCoursesTaught] addObject:value];
    [self didChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeCoursesTaughtObject:(PXCourse *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveCoursesTaught] removeObject:value];
    [self didChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addCoursesTaught:(NSSet *)value {    
    [self willChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveCoursesTaught] unionSet:value];
    [self didChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCoursesTaught:(NSSet *)value {
    [self willChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveCoursesTaught] minusSet:value];
    [self didChangeValueForKey:@"coursesTaught" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (PXDocument *)documentsOwned {
    id tmpObject;
    
    [self willAccessValueForKey:@"documentsOwned"];
    tmpObject = [self primitiveDocumentsOwned];
    [self didAccessValueForKey:@"documentsOwned"];
    
    return tmpObject;
}

- (void)setDocumentsOwned:(PXDocument *)value {
    [self willChangeValueForKey:@"documentsOwned"];
    [self setPrimitiveDocumentsOwned:value];
    [self didChangeValueForKey:@"documentsOwned"];
}

- (BOOL)validateDocumentsOwned:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

#endif

@end

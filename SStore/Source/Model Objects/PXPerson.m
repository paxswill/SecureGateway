//
//  PXPerson.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import "PXPerson.h"


@implementation PXPerson
@dynamic email;
@dynamic idNumber;
@dynamic admin;
@dynamic name;
@dynamic passwordHash;
@dynamic availableDocuments;

- (void)addAvailableDocumentsObject:(PXDocument *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveAvailableDocuments] addObject:value];
    [self didChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeAvailableDocumentsObject:(PXDocument *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveAvailableDocuments] removeObject:value];
    [self didChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addAvailableDocuments:(NSSet *)value {    
    [self willChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveAvailableDocuments] unionSet:value];
    [self didChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeAvailableDocuments:(NSSet *)value {
    [self willChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveAvailableDocuments] minusSet:value];
    [self didChangeValueForKey:@"availableDocuments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif

@end

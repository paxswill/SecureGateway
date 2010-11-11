//
//  PXPerson.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import "PXPerson.h"


@implementation PXPerson
@dynamic email;
@dynamic idNumber;
@dynamic admin;
@dynamic name;
@dynamic passwordHash;
@dynamic availableDocuments;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (NSString *)email {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"email"];
    tmpValue = [self primitiveEmail];
    [self didAccessValueForKey:@"email"];
    
    return tmpValue;
}

- (void)setEmail:(NSString *)value {
    [self willChangeValueForKey:@"email"];
    [self setPrimitiveEmail:value];
    [self didChangeValueForKey:@"email"];
}

- (BOOL)validateEmail:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSData *)idNumber {
    NSData * tmpValue;
    
    [self willAccessValueForKey:@"idNumber"];
    tmpValue = [self primitiveIdNumber];
    [self didAccessValueForKey:@"idNumber"];
    
    return tmpValue;
}

- (void)setIdNumber:(NSData *)value {
    [self willChangeValueForKey:@"idNumber"];
    [self setPrimitiveIdNumber:value];
    [self didChangeValueForKey:@"idNumber"];
}

- (BOOL)validateIdNumber:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)admin {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"admin"];
    tmpValue = [self primitiveAdmin];
    [self didAccessValueForKey:@"admin"];
    
    return tmpValue;
}

- (void)setAdmin:(NSNumber *)value {
    [self willChangeValueForKey:@"admin"];
    [self setPrimitiveAdmin:value];
    [self didChangeValueForKey:@"admin"];
}

- (BOOL)validateAdmin:(id *)valueRef error:(NSError **)outError {
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

- (NSData *)passwordHash {
    NSData * tmpValue;
    
    [self willAccessValueForKey:@"passwordHash"];
    tmpValue = [self primitivePasswordHash];
    [self didAccessValueForKey:@"passwordHash"];
    
    return tmpValue;
}

- (void)setPasswordHash:(NSData *)value {
    [self willChangeValueForKey:@"passwordHash"];
    [self setPrimitivePasswordHash:value];
    [self didChangeValueForKey:@"passwordHash"];
}

- (BOOL)validatePasswordHash:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

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

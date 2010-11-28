//
//  PXPerson.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXPerson.h"


@implementation PXPerson

@synthesize name;
@synthesize email;
@synthesize idNumber;
@synthesize admin;
@synthesize pwHash;

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

@end

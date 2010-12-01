//
//  PXCourse.m
//  SStore
//
//  Created by Will Ross on 11/30/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXCourse.h"


@implementation PXCourse

@synthesize instructor;
@synthesize  students;

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

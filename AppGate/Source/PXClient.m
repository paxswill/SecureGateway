//
//  PXClient.m
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXClient.h"


@implementation PXClient

@synthesize port;
@synthesize delegate;
@synthesize host;
@dynamic connected;

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

-(BOOL)connectToServer:(NSString*)host onPort:(int)portNum{
	
}

@end

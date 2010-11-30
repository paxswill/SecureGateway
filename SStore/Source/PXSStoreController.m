//
//  PXSStoreController.m
//  SStore
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSStoreController.h"


@implementation PXSStoreController

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithConfiguration:(NSDictionary *)config{
	if((self = [self init])){
		//Get the config parameters
		int port = [[config objectForKey:@"portNumber"] intValue];
		NSURL *certURL = [NSURL URLWithString:[config objectForKey:@"CACertificate"]];
		NSURL *keyURL = [NSURL URLWithString:[config objectForKey:@"keyFile"]];
		NSString *keyPassword = [config objectForKey:@"keyPassword"];
		NSString *dbFile = [config objectForKey:@"dbFile"];
		NSString *dbPassword = [config objectForKey:@"dbPassword"];
		
		//Make the server
		//Create the server
		PXServer *server = [[PXServer alloc] init];
		server.port = port;
		if(![server openSocket]){
			NSLog(@"Fatal error in opening socket. Try re-running the program");
			return nil;
		}
		[server listenForConnections];
		
		//Open the store
		storage = [[PXSQLiteRecords alloc] initDatabaseAtLocation:dbFile withPassword:dbPassword];
	}
	return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

@end

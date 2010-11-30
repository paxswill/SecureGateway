//
//  PXSStoreController.m
//  SStore
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSStoreController.h"


@implementation PXSStoreController

@synthesize server;

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
		certURL = [NSURL URLWithString:[config objectForKey:@"certificateFile"]];
		keyURL = [NSURL URLWithString:[config objectForKey:@"keyFile"]];
		keyPassword = [config objectForKey:@"keyPassword"];
		NSString *dbFile = [config objectForKey:@"dbFile"];
		NSString *dbPassword = [config objectForKey:@"dbPassword"];
		
		//Make the server
		//Create the server
		server = [[PXServer alloc] init];
		server.port = port;
		server.delegate = self;
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

-(void)jumpToSecure{
	[self.server sendString:@"goSecure"];
}

-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection{
	if(data == nil && connection == nil){
		//This si the signal that The server is now listening
		
	}
	NSString *recievedString = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSLog(@"Recieved%@:\n%@", (self.server.secure ? @" securely": @""), recievedString);
	[self processAppGateCommand:recievedString];
	[recievedString release];
}

-(void)processAppGateCommand:(NSString *)cmd{
	NSArray *cmdComponents = [cmd componentsSeparatedByString:@" "];
	NSString *keyWord = [cmdComponents objectAtIndex:0];
	if([keyWord isEqualToString:@"goSecure"]){
		//Acknowledge
		//Set up SSL
		[server loadCertChain:certURL];
		[server loadKey:keyURL withPassword:keyPassword];
		[server prepareSSLConnection];
		//Switch up to SSL
		[server openSSLConnection];
	}
}

@end

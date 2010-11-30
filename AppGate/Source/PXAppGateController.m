//
//  PXAppGateController.m
//  AppGate
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXAppGateController.h"


@implementation PXAppGateController

@synthesize client;
@synthesize authenticatedUsers;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
		authenticatedUsers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(id)initWithConfiguration:(NSDictionary *)configDict{
	if((self = [self init])){
		//Load the config options
		NSString *host = [configDict objectForKey:@"storeHost"];
		int port = [[configDict objectForKey:@"portNumber"] intValue];
		NSURL *certURL = [NSURL URLWithString:[configDict objectForKey:@"CACertificate"]];
		NSURL *keyURL = [NSURL URLWithString:[configDict objectForKey:@"keyFile"]];
		NSString *keyPassword = [configDict objectForKey:@"keyPassword"];
		
		//Load the client up
		client = [[PXClient alloc] init];
		client.delegate = self;
		if(![client connectToServer:host onPort:port]){
			NSLog(@"Connection failed");
			return nil;
		}else{
			NSLog(@"Connection succeeded!");
		}
		
		[client listen];
		
		[client prepareSSLConnection];
		[client loadCA:certURL];
		[client loadKey:keyURL withPassword:keyPassword];
	}
	return self;
}

- (void)dealloc {
    // Clean-up code here.
    [client closeConnection];
    [super dealloc];
}

-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection{
	NSString *recievedString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	NSLog(@"Recieved:\n%@", recievedString);
	[self processSStoreCommand:recievedString];
	[recievedString release];
}

-(void)processSStoreCommand:(NSString *)cmd{
	NSArray *cmdComponents = [cmd componentsSeparatedByString:@" "];
	NSString *keyWord = [[cmdComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	if([keyWord isEqualToString:@"goSecure"]){
		//Acknowledge
		[client sendString:@"goSecure"];
		//Switch up to SSL
		while(![self.client openSSLConnection]){
			sleep(1);
		}
	}else if([keyWord isEqualToString:@"authenticated"]){
		//A user has been authenticated
		//Key is the username
		//Value is the IP address/cookie associated with the user
		//TODO: Actually have a cookie to store 
		[self.authenticatedUsers setObject:@"foo" forKey:[cmdComponents objectAtIndex:1]];
	}else if([keyWord isEqualToString:@"object"]){
		//Now the server is returning the object the client requested.
		//the object at index 1 is the hex encoded object
		//TODO: Reassemble the object
	}
}


@end

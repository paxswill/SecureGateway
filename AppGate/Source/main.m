//
//  main.m
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXClient.h"

int main (int argc, const char * argv[]) {
	//Make an autorelease pool
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//If no path given, set the default one
	NSString *configPath;
	if(argc == 2){
		configPath = [NSString stringWithUTF8String:argv[1]];
	}else{
		configPath = @"./config.plist";
	}
	//Read in the configuration variables
	NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:configPath];
	if(configuration == nil){
		//The configuration is invalid.
		NSLog(@"Invalid Cnfiguration file. Either place a proper plist named 'config.plist' in the current directory, or specify one following the command.");
		exit(1);
	}
	NSString *host = [configuration objectForKey:@"storeHost"];
	int port = [[configuration objectForKey:@"portNumber"] intValue];
	NSURL *certURL = [NSURL URLWithString:[configuration objectForKey:@"CACertificate"]];
	NSURL *keyURL = [NSURL URLWithString:[configuration objectForKey:@"keyFile"]];
	NSString *keyPassword = [configuration objectForKey:@"keyPassword"];
	
	//This is just testing the client
	PXClient *testClient = [[PXClient alloc] init];
	if(![testClient connectToServer:host onPort:port]){
		NSLog(@"Connection failed");
	}else{
		NSLog(@"Connection succeeded!");
	}
	[testClient prepareSSLConnection];
	[testClient loadCA:certURL];
	[testClient loadKey:keyURL withPassword:keyPassword];
	[testClient openSSLConnection];
	
	[testClient closeConnection];

	[pool drain];
    return 0;
}


//
//  main.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import <objc/objc-auto.h>
#import <unistd.h>


#import "PXServer.h"
#import "PXFaculty.h"
#import "PXSQLiteRecords.h"

void testServer(int argc, const char **argv);

int main (int argc, const char * argv[]) {
	//Start Garbage Collection
	objc_startCollectorThread();
	
	//Load the config file in
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
	int port = [[configuration objectForKey:@"portNumber"] intValue];
	NSURL *certURL = [NSURL URLWithString:[configuration objectForKey:@"CACertificate"]];
	NSURL *keyURL = [NSURL URLWithString:[configuration objectForKey:@"keyFile"]];
	NSString *keyPassword = [configuration objectForKey:@"keyPassword"];
	NSString *dbFile = [configuration objectForKey:@"dbFile"];
	NSString *dbPassword = [configuration objectForKey:@"dbPassword"];
	
	//Create the server
	PXServer *server = [[PXServer alloc] init];
	server.port = port;
	if(![server openSocket]){
		NSLog(@"Fatal error in opening socket. Try re-running the program");
		exit(1);
	}
	
	//Loop, waiting a quarter of a second between polling
	struct timespec sleepTime;
	sleepTime.tv_sec = 0;
	sleepTime.tv_nsec = 250000000;
	while(![server checkConnection]){
		nanosleep(&sleepTime, NULL);
	}
	NSLog(@"Connection ready");
	[server openConnection];
	
	NSString *testString = @"Testing output\n";
	[server send:[NSData dataWithBytes:[testString UTF8String] length:([testString length] + 1)]];
	
	//Try setting up SSL
	[server prepareSSLConnection];
	[server loadCA:certURL];
	[server loadKey:keyURL withPassword:keyPassword];
	[server openSSLConnection];
	
	PXSQLiteRecords *storage;
	if(server.secure){
		//Open the database
		storage = [[PXSQLiteRecords alloc] initDatabaseAtLocation:dbFile withPassword:dbPassword];
	}else{
		[server closeSocket];
		return 1;
	}
	
	//TODO: Put a polling loop in here so we can read in the files
	
	
	
	//Close the connection
	[server closeSocket];
}

void testServer(int argc, const char **argv){
	//If no path given, set the default one
	
	
	//Testing:
	//Start a server
	
}


//
//  main.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import <unistd.h>


#import "PXSStoreController.h"

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	
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
	
	PXSStoreController *controller = [[PXSStoreController alloc] initWithConfiguration:configuration];
	//Wait to connect
	while(controller.server.lookingForConnection){sleep(1);};
	//Ok, now were connected and listening
	while(!controller.server.listening){sleep(1);};
	[controller jumpToSecure];
	//Wait for security
	while(!controller.server.secure){sleep(1);};
	NSLog(@"Connection secure");
	[controller.server sendString:@"Secure Test!"];
	
	
	[pool drain];
}


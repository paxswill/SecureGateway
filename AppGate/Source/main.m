//
//  main.m
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXAppGateController.h"

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
	
	PXAppGateController *controller = [[PXAppGateController alloc] initWithConfiguration:configuration];
	
	//Block while we do stuff in the controller
	while(controller.client.listeningForData){sleep(3);};

	[pool drain];
    return 0;
}


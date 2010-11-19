//
//  PXServer.m
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import "PXServer.h"

//Private methods
@interface PXServer(){
    
}

void socketCallback(CFSocketRef sock, CFSocketCallBackType callType, CFDataRef address, const void *data, void *info);
@end


@implementation PXServer

@synthesize port;
@synthesize delegate;
@synthesize host;
@synthesize socket;


#pragma mark Memory Management/Housekeeping
- (id)init {
    if ((self = [super init])) {
        //Set a default port
		//6968 is an unregistered port (but within the IANA registered port range)
		//I just chose it as it was my student number in middle school
		port = 6968;
		//Set a defualt Host.
		//Host is nil at first, as the server will accept connections form anywhere
		host = nil;
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

#pragma mark -
#pragma mark Sockets fun

-(BOOL)openSocket{
	//Create the socket
	self.socket = CFSocketCreate(NULL, PF_INET, 0, IPPROTO_TCP, kCFSocketDataCallBack, (*socketCallback), NULL);
	//Create the run loop source
	CFRunLoopSourceRef socketLoopSource = CFSocketCreateRunLoopSource(NULL, self.socket, 0);
	//Get a run loop
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFRetain(runLoop);
	//Add the socket source to the loop
	CFRunLoopAddSource(runLoop, socketLoopSource, kCFRunLoopCommonModes);
	//Start the loop
	CFRunLoopRun();
	//Clean up
	CFRelease(runLoop);
	CFRelease(socketLoopSource);
	return YES;
}

void socketCallback(CFSocketRef sock, CFSocketCallBackType callType, CFDataRef address, const void *data, void *info){
	NSLog(@"Connection and/or data!");
}



-(void)send:(NSData *)data{
	
}


@end

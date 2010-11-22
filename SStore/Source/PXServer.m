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

@property (readwrite, nonatomic) int incomingSocket;
@property (readwrite, nonatomic) int connectedSocket;

-(void)checkConnection;
-(void)openConnection;
@end


@implementation PXServer

@synthesize port;
@synthesize delegate;
@synthesize host;
@synthesize incomingSocket;
@synthesize connectedSocket;
@dynamic connected;


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
		//Set default/sentinel values to the file handles
		incomingSocket = INT_MIN;
		connectedSocket = INT_MIN;
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
	//Status var used for return codes
	int status;
	//Create the socket
	self.incomingSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(self.incomingSocket == -1){
		//We dun goofed. Socket not created
		NSLog(@"Socket failed to allocate. Aborting Server creation");
		return NO;
	}
	
	//Set up the address
	struct sockaddr_in serverAddress;
	//Clear the memory out
	memset(&serverAddress, 0, sizeof(serverAddress));
	//Set up the server address
	serverAddress.sin_family = AF_INET;
	//Since this is the default constructor, we have to set a default port
	serverAddress.sin_port = htons(self.port);
	//Accept any connection
	serverAddress.sin_addr.s_addr = INADDR_ANY;
	
	//Bind the socket
	status = bind(self.incomingSocket, (const struct sockaddr*)(&serverAddress), sizeof(serverAddress));
	if(status == -1){
		NSLog(@"Binding failed.");
		return NO;
	}
	
	//Start listening
	//The backlog limit /should/ be user configuarable, but for now it's going to be static
	//For info: On OS X (according to the listen man page), backlog is limited to 128
	status = listen(self.incomingSocket, 25);
	if(status == -1){
		NSLog(@"Setting socket to listen failed.");
		return NO;
	}
	
	//Watch for an incoming connection in the run loop
	NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
	[runLoop performSelector:@selector(checkConnection) target:self argument:nil order:0 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
	
	//All done
	return YES;
}

-(void)checkConnection{
	//Do we have an incoming connection?
	fd_set incomingSocketSet;
	FD_SET(self.incomingSocket, &incomingSocketSet);
	struct timeval zeroTime;
	zeroTime.tv_sec = 0;
	zeroTime.tv_usec = 0;
	int numReadySockets = select(self.incomingSocket + 1, &incomingSocketSet, NULL, NULL, &zeroTime);
	BOOL isSocketReady = FD_ISSET(self.incomingSocket, &incomingSocketSet) != 0? YES : NO;
	if(numReadySockets > 1 && isSocketReady){
		//This job normally gets removed, so we don't need to explicitly remove ourselves
		[self openConnection];
	}else{
		// Normally this method will get removed from the run loop after it is invoked.
		// Now we add it back in.
		[[NSRunLoop mainRunLoop] performSelector:@selector(checkConnection) target:self argument:nil order:0 modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
	}
}

-(void)openConnection{
	//At this time, the socket should have an incoming connection
	struct sockaddr_in *clientAddress;
	socklen_t clientAddressLength;
	self.connectedSocket = accept(self.incomingSocket, (struct sockaddr *)clientAddress, &clientAddressLength);
	if(self.connectedSocket < 0){
		NSLog(@"Connection failed. Closing out.");
		close(self.incomingSocket);
	}
	//This can sometimes take a while to load in, as it willdo DNS resolution. So we spawn it off into a cheapo thread
	char *addressCString = inet_ntoa(clientAddress->sin_addr);
	self.host = [NSHost hostWithAddress:[NSString stringWithUTF8String:addressCString]];
}



-(void)send:(NSData *)data{
	
}

#pragma mark -
#pragma mark Custom Properties

-(BOOL)isConnected{
	return (self.incomingSocket != INT_MIN && self.connectedSocket != INT_MIN);
}


@end

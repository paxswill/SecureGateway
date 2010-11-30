//
//  PXServer.m
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

#import "PXServer.h"
#import <errno.h>

//Private methods
@interface PXServer()

//Private overrides of parent properties (for read/write
@property (readwrite, nonatomic, getter=isConnected) BOOL connected;
@property (readwrite, nonatomic, getter=isSecure) BOOL secure;
@property (readwrite, nonatomic, getter=isListening) BOOL listening;

-(void)privateListenForConnections;

@end


@implementation PXServer

@synthesize connected;
@synthesize secure;
@synthesize listeningSocket;
@synthesize listening;
@synthesize lookingForConnection;

#pragma mark Memory Management/Housekeeping
- (id)init {
    if ((self = [super init])) {
        incomingListenThread = [[NSThread alloc] initWithTarget:self selector:@selector(privateListenForConnections) object:nil];
    }
    return self;
}

- (void)dealloc {
	//Shut the socket down
	[self closeSocket];
    [super dealloc];
}

#pragma mark -
#pragma mark Sockets Operations

-(BOOL)openSocket{
	//Status var used for return codes
	int status;
	//Create the socket
	self.listeningSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(self.listeningSocket == -1){
		//We dun goofed. Socket not created
		NSLog(@"Socket failed to allocate. Aborting Server creation. Error: %s", strerror(errno));
		return NO;
	}
	
	//We want to be able to resue the socket, as sometimes 
	// we don't exit so cleanly (like now!)
	int enabled = 1;
	setsockopt(self.listeningSocket, SOL_SOCKET, SO_REUSEPORT, &enabled, sizeof(int));
	//We do not block in this program, we poll
	//fcntl(self.listeningSocket, F_SETFL, O_NONBLOCK);
	
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
	status = bind(self.listeningSocket, (const struct sockaddr*)(&serverAddress), sizeof(serverAddress));
	if(status == -1){
		NSLog(@"Binding failed. Error: %s", strerror(errno));
		close(self.listeningSocket);
		return NO;
	}
	
	//Start listening
	//The backlog limit /should/ be user configuarable, but for now it's going to be static
	//For info: On OS X (according to the listen man page), backlog is limited to 128
	status = listen(self.listeningSocket, 25);
	if(status == -1){
		NSLog(@"Setting socket to listen failed. Error: %s", strerror(errno));
		close(self.listeningSocket);
		return NO;
	}
	
	//All done
	return YES;
}

-(void)closeSocket{
	//Stop listening
	[listenThread cancel];
	//Close the sockets out
	shutdown(self.mainSocket, SHUT_RDWR);
	close(self.mainSocket);
	close(self.listeningSocket);
	//Put the sentinel values back
	self.mainSocket = INT_MIN;
	self.listeningSocket = INT_MIN;
}

-(BOOL)checkConnection:(int)connection{
	//Do we have an incoming connection?
	fd_set incomingSocketSet;
	FD_SET(connection, &incomingSocketSet);
	struct timeval zeroTime;
	zeroTime.tv_sec = 0;
	zeroTime.tv_usec = 0;
	int numReadySockets = select(connection + 1, &incomingSocketSet, NULL, NULL, &zeroTime);
	BOOL isSocketReady = FD_ISSET(connection, &incomingSocketSet) != 0? YES : NO;
	return isSocketReady && numReadySockets > 0;
}

-(void)openConnection{
	//At this time, the socket should have an incoming connection
	struct sockaddr_in *clientAddress;
	socklen_t clientAddressLength;
	self.mainSocket = accept(self.listeningSocket, (struct sockaddr *)clientAddress, &clientAddressLength);
	if(self.mainSocket < 0){
		NSLog(@"Connection failed. Closing out. Error: %s", strerror(errno));
		close(self.listeningSocket);
	}
	//This can sometimes take a while to load in, as it willdo DNS resolution. So we spawn it off into a cheapo thread
	//char *addressCString = inet_ntoa(clientAddress->sin_addr);
	//self.host = [NSHost hostWithAddress:[NSString stringWithUTF8String:addressCString]];
}



-(void)send:(NSData *)data{
	if(!self.connected){
		//Fail fast, we're not connected
		return;
	}
	//If we're not connected via SSL, send in the clear
	if(!self.secure){
		//So now we're positive we're connected;
		int status = send(self.mainSocket, [data bytes], [data length], 0);
		if(status < 0){
			NSLog(@"Error sending data : %s", strerror(errno));
		}
	}else{
		//We're secured, so use SSL_write
		int status = SSL_write(self.sslConnection, [data bytes], [data length]);
		if(status < 0){
			NSLog(@"Error sending data : %d", SSL_get_error(self.sslConnection, status));
		}
	}
}

-(void)listenForConnections{
	self.lookingForConnection = YES;
	[incomingListenThread start];
}

-(void)listen{
	self.listening = YES;
	self.lookingForConnection = NO;
	[listenThread start];
}

-(void)privateListenForConnections{
	//Autorelease pool
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	struct timespec sleepTime;
	sleepTime.tv_sec = 0;
	sleepTime.tv_nsec = 250000000;
	while(![self checkConnection:self.listeningSocket]){
		nanosleep(&sleepTime, NULL);
	}
	[self openConnection];
	//Connection now open. Signal that we want to go secure now
	[pool drain];
	[self listen];
	[NSThread exit];
}

#pragma mark -
#pragma mark SSL Methods

-(BOOL)openSSLConnection{
	int err = SSL_accept(self.sslConnection);
	if(err == 1){
		//connection ready
		self.secure = YES;
	}else{
		//There's an error
		unsigned long errorNum = ERR_get_error();
		NSLog(@"There's an SSL error in library '%s', function '%s', reason: %s", ERR_lib_error_string(errorNum), ERR_func_error_string(errorNum), ERR_reason_error_string(errorNum));
	}
	return self.secure;
}


#pragma mark -
#pragma mark Custom Properties

-(BOOL)isConnected{
	return (self.listeningSocket != INT_MIN && self.mainSocket != INT_MIN);
}


@end

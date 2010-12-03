//
//  PXMultiServer.m
//  AppGate
//
//  Created by Will Ross on 12/3/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXMultiServer.h"

@interface PXMultiServer()
@property (readwrite, nonatomic, getter=isConnected) BOOL connected;
@property (readwrite, nonatomic, getter=isSecure) BOOL secure;
	@property (readwrite, nonatomic, getter=isListeningForData) BOOL listeningForData;
-(void)privateListen;
@end


@implementation PXMultiServer

@synthesize fd2ip, ip2fd;
@synthesize connected;
@synthesize secure;
@synthesize listeningForData;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
		fd2ip = [[NSMutableDictionary alloc] init];
		ip2fd = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}


//These two methods are really close, just some optimization for speed and
// additions for extra connection tracking

-(void)openConnection:(int)socketNum{
	//At this time, the socket should have an incoming connection
	struct sockaddr_in *clientAddress;
	socklen_t clientAddressLength;
	int newDataSocket = accept(socketNum, (struct sockaddr *)clientAddress, &clientAddressLength);
	if(newDataSocket < 0){
		NSLog(@"Connection failed. Closing out. Error: %s", strerror(errno));
		close(self.listeningSocket);
	}
	//Now save the info (file handle, IP address) in the dictionary
	NSNumber *fd = [NSNumber numberWithInt:newDataSocket];
	NSString *ip = [NSString stringWithUTF8String:inet_ntoa(clientAddress->sin_addr)];
	[self.ip2fd setObject:fd forKey:ip];
	[self.fd2ip setObject:ip forKey:fd];
}

-(void)privateListen{
	//Make an autorelease pool
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	while(![listenThread isCancelled] && self.connected){
		//Is there stuff to read?
		fd_set listenSet;
		FD_SET(self.mainSocket, &listenSet);
		struct timeval zeroTime;
		zeroTime.tv_sec = 0;
		zeroTime.tv_usec = 50;
		int numReadySockets = select(self.mainSocket + 1, &listenSet, NULL, NULL, &zeroTime);
		BOOL isSocketReady = FD_ISSET(self.mainSocket, &listenSet) != 0? YES : NO;
		if(numReadySockets > 0 && isSocketReady && self.delegate != nil){
			//Prepare the buffers (5MB buffer)
			size_t bufferSize = 5*1024*1024;
			void *buffer = malloc(bufferSize);
			ssize_t numBytesRead;
			//Use SSL_read for secure connections
			if(self.secure){
				numBytesRead = SSL_read(self.sslConnection, buffer, bufferSize);
			}else{
				numBytesRead = read(self.mainSocket, buffer, bufferSize);
			}
			//Is the connection broken?
			if(numBytesRead == 0){
				NSLog(@"Connection Broken");
				self.connected = NO; 
				[NSThread exit];
			}
			//Give the data to the delegate
			[delegate recievedData:[NSData dataWithBytes:buffer length:numBytesRead] fromConnection:self];
			free(buffer);
		}
	}
	//Drain the pool
	[pool drain];
}

@end

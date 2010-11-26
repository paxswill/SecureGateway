//
//  PXClient.m
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXClient.h"
#import <errno.h>

@interface PXClient(){
}
@property (readwrite, nonatomic) int socketConnection;
@property (readwrite, nonatomic, getter=isConnected) BOOL connected;
@end

@implementation PXClient

@synthesize port;
@synthesize delegate;
@synthesize socketConnection;
@synthesize connected;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

-(BOOL)connectToServer:(NSString*)host onPort:(int)portNum{
	//Make a socket
	self.socketConnection = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(self.socketConnection ==-1){
		NSLog(@"Failure in allocating Socket. Error: %s", strerror(errno));
		return NO;
	}
	
	//Set up where to connect to
	struct sockaddr_in serverAddress;
	//Clear the struct out
	memset(&serverAddress, 0, sizeof(serverAddress));
	//Where is ther connection parameters
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_port = htons(portNum);
	//Set up the server address
	int ret = inet_pton(AF_INET, [host UTF8String], &serverAddress.sin_addr);
	if(ret == 0){
		//Address given is not valid
		NSLog(@"Address given is not valid");
		close(self.socketConnection);
		return NO;
	}
	//Actually try connecting
	int status = connect(self.socketConnection, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
	if(status == -1){
		//Failure to connect
		NSLog(@"Failure to connect to server.");
		close(self.socketConnection);
		return NO;
	}
	//All don and connected
	self.connected = YES;
	return YES;
}

-(void)closeConnection{
	shutdown(self.socketConnection, SHUT_RDWR);
	close(self.socketConnection);
	self.connected = NO;
}

-(void)send:(NSData *)data{
	if(!self.connected){
		//Fail fast, we're no connected
		return;
	}
	//So now we're positive we're connected;
	int status = send(self.socketConnection, [data bytes], [data length], 0);
	if(status < 0){
		NSLog(@"Error sending data : %s", strerror(errno));
	}
}

-(BOOL)isConnected{
	return NO;
}

@end

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
@property (readwrite, nonatomic, getter=isConnected) BOOL connected;
@property (readwrite, nonatomic, getter=isSecure) BOOL secure;

@end

@implementation PXClient

@synthesize connected;
@synthesize secure;


- (id)init {
    if ((self = [super init])) {
		
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    //TODO: Close the socket
    [super dealloc];
}

-(BOOL)connectToServer:(NSString*)host onPort:(int)portNum{
	//Make a socket
	self.mainSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(self.mainSocket ==-1){
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
		close(self.mainSocket);
		return NO;
	}
	//Actually try connecting
	int status = connect(self.mainSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
	if(status == -1){
		//Failure to connect
		NSLog(@"Failure to connect to server.");
		close(self.mainSocket);
		return NO;
	}
	//All don and connected
	self.connected = YES;
	return YES;
}

-(void)closeConnection{
	shutdown(self.mainSocket, SHUT_RDWR);
	close(self.mainSocket);
	self.connected = NO;
}

#pragma mark -
#pragma mark SSL Methods

-(BOOL)openSSLConnection{
	//Now connect
	return (SSL_connect(self.sslConnection) == 1 ? YES : NO);
}

-(void)send:(NSData *)data{
	if(!self.connected){
		//Fail fast, we're not connected
		return;
	}
	//If we're not connected via SSL, send in the clear
	if(!self.secure){
		int status = send(self.mainSocket, [data bytes], [data length], 0);
		if(status < 0){
			NSLog(@"Error sending data : %s", strerror(errno));
		}
	}else{
		//We're secured, so use SSL_write
		int status = SSL_write(self.sslConnection, [data bytes], [data length]);
		if(status < 0){
			NSLog(@"Error sending data : %d", SSL_get_error(sslConnection, status));
		}
	}
	
}

@end





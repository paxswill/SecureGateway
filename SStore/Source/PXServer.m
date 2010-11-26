//
//  PXServer.m
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

#import "PXServer.h"
#import <errno.h>

//OpenSSL
#include "openssl/bio.h"
#include "openssl/ssl.h"
#include "openssl/err.h"

//Private methods
@interface PXServer(){
    
}

@property (readwrite, nonatomic) int incomingSocket;
@property (readwrite, nonatomic) int connection;

@end


@implementation PXServer

@synthesize port;
@synthesize delegate;
@synthesize incomingSocket;
@synthesize connection;
@dynamic connected;


#pragma mark Memory Management/Housekeeping
- (id)init {
    if ((self = [super init])) {
        //Set a default port
		//6968 is an unregistered port (but within the IANA registered port range)
		//I just chose it as it was my student number in middle school
		port = 6968;
		//Set default/sentinel values to the file handles
		incomingSocket = INT_MIN;
		connection = INT_MIN;
		
		//Initialize OpenSSL
		SSL_load_error_strings();
		ERR_load_BIO_strings();
		OpenSSL_add_all_algorithms();
		SSL_library_init();
		sslMethod = TLSv1_method();
		sslContext = SSL_CTX_new(sslMethod);
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
	self.incomingSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(self.incomingSocket == -1){
		//We dun goofed. Socket not created
		NSLog(@"Socket failed to allocate. Aborting Server creation. Error: %s", strerror(errno));
		return NO;
	}
	
	//We want to be able to resue the socket, as sometimes 
	// we don't exit so cleanly (like now!)
	int enabled = 1;
	setsockopt(self.incomingSocket, SOL_SOCKET, SO_REUSEPORT, &enabled, sizeof(int));
	//We do not block in this program, we poll
	fcntl(self.incomingSocket, F_SETFL, O_NONBLOCK);
	
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
		NSLog(@"Binding failed. Error: %s", strerror(errno));
		close(self.incomingSocket);
		return NO;
	}
	
	//Start listening
	//The backlog limit /should/ be user configuarable, but for now it's going to be static
	//For info: On OS X (according to the listen man page), backlog is limited to 128
	status = listen(self.incomingSocket, 25);
	if(status == -1){
		NSLog(@"Setting socket to listen failed. Error: %s", strerror(errno));
		close(self.incomingSocket);
		return NO;
	}
	
	//All done
	return YES;
}

-(void)closeSocket{
	//Close the sockets out
	shutdown(self.connection, SHUT_RDWR);
	close(self.connection);
	close(self.incomingSocket);
	//Put the sentinel values back
	self.connection = INT_MIN;
	self.incomingSocket = INT_MIN;
}

-(BOOL)checkConnection{
	//Do we have an incoming connection?
	fd_set incomingSocketSet;
	FD_SET(self.incomingSocket, &incomingSocketSet);
	struct timeval zeroTime;
	zeroTime.tv_sec = 0;
	zeroTime.tv_usec = 0;
	int numReadySockets = select(self.incomingSocket + 1, &incomingSocketSet, NULL, NULL, &zeroTime);
	BOOL isSocketReady = FD_ISSET(self.incomingSocket, &incomingSocketSet) != 0? YES : NO;
	return isSocketReady && numReadySockets > 0;
}

-(void)openConnection{
	//At this time, the socket should have an incoming connection
	struct sockaddr_in *clientAddress;
	socklen_t clientAddressLength;
	self.connection = accept(self.incomingSocket, (struct sockaddr *)clientAddress, &clientAddressLength);
	if(self.connection < 0){
		NSLog(@"Connection failed. Closing out. Error: %s", strerror(errno));
		close(self.incomingSocket);
	}
	//This can sometimes take a while to load in, as it willdo DNS resolution. So we spawn it off into a cheapo thread
	//char *addressCString = inet_ntoa(clientAddress->sin_addr);
	//self.host = [NSHost hostWithAddress:[NSString stringWithUTF8String:addressCString]];
}



-(void)send:(NSData *)data{
	if(!self.connected){
		//Fail fast, we're no connected
		return;
	}
	//So now we're positive we're connected;
	int status = send(self.connection, [data bytes], [data length], 0);
	if(status < 0){
		NSLog(@"Error sending data : %s", strerror(errno));
	}
}

#pragma mark -
#pragma mark SSL Methods

-(void)loadCertificate:(NSURL*)privateKey{
	SSL_CTX_use_PrivateKey_file(sslContext, [privateKey path], SSL_FILETYPE_PEM);
}

-(void)loadCA:(NSURL*)certificate{
	SSL_CTX_use_certificate_file(sslContext, [certificate path], SSL_FILETYPE_PEM);
}

#pragma mark -
#pragma mark Custom Properties

-(BOOL)isConnected{
	return (self.incomingSocket != INT_MIN && self.connection != INT_MIN);
}


@end

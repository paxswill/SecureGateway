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

#pragma mark -
#pragma mark SSL Methods

-(void)loadCertificate:(NSURL*)privateKey{
	SSL_CTX_use_PrivateKey_file(sslContext, [[privateKey path] UTF8String], SSL_FILETYPE_PEM);
}

-(void)loadCA:(NSURL*)certificate{
	SSL_CTX_use_certificate_file(sslContext, [[certificate path] UTF8String], SSL_FILETYPE_PEM);
}

-(BOOL)openSSLConnection{
	//Force client verification, using the default checking
	SSL_CTX_set_verify(sslContext, SSL_VERIFY_PEER, NULL);
	//Make the SSL object
	sslConnection = SSL_new(sslContext);
	//Make and configure the BIO object
	bioConnection = BIO_new(BIO_s_socket());
	BIO_set_fd(bioConnection, self.socketConnection, BIO_NOCLOSE);
	//Bind the BIO and SSL objects together
	SSL_set_bio(sslConnection, bioConnection, bioConnection);
	//Now connect
	return (SSL_connect(sslConnection) == 1 ? YES : NO);
}

-(void)send:(NSData *)data{
	if(!self.connected){
		//Fail fast, we're not connected
		return;
	}
	//If we're not connected via SSL, send in the clear
	if(!secured){
		//So now we're positive we're connected;
		int status = send(self.socketConnection, [data bytes], [data length], 0);
		if(status < 0){
			NSLog(@"Error sending data : %s", strerror(errno));
		}
	}else{
		//We're secured, so use SSL_write
		int status = SSL_write(sslConnection, [data bytes], [data length]);
		if(status < 0){
			NSLog(@"Error sending data : %d", SSL_get_error(sslConnection, status));
		}
	}
	
}

@end

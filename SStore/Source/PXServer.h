//
//  PXServer.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXConnection.h"
#import "PXConnectionDelegate.h"

//Sockets
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

//OpenSSL
#include "openssl/bio.h"
#include "openssl/ssl.h"
#include "openssl/err.h"

@interface PXServer : NSObject<PXConnection> {
@private
	int port;
	id<PXConnectionDelegate> delegate;
	//Sockets
	int incomingSocket;
	int connection;
	//SSL Hell
	SSL_METHOD *sslMethod;
	SSL_CTX *sslContext;
	SSL *sslConnection;
	BIO *bioConnection;
	BOOL secured;
}

@property (readwrite, nonatomic) int port;
@property (readwrite, nonatomic) id<PXConnectionDelegate> delegate;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

-(BOOL)openSocket;
-(void)closeSocket;
-(BOOL)checkConnection;
-(void)openConnection;
-(void)send:(NSData *)data;

//SSL fun
-(void)loadCertificate:(NSURL*)privateKey;
-(void)loadCA:(NSURL*)certificate;
-(void)configureSSL;
@end

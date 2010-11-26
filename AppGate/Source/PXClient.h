//
//  PXClient.h
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXConnection.h"

//Sockets
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

//OpenSSL
#include "openssl/bio.h"
#include "openssl/ssl.h"
#include "openssl/err.h"

@interface PXClient : NSObject<PXConnection> {
@private
	int port;
	id<PXConnectionDelegate> delegate;
    BOOL connected;
	int socketConnection;
	//SSL members
	SSL_METHOD *sslMethod;
	SSL_CTX *sslContext;
	SSL *sslConnection;
	BIO *bioConnection;
	BOOL secured;
}

@property (readwrite, nonatomic) int port;
@property (readwrite, nonatomic, assign) id<PXConnectionDelegate> delegate;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

-(BOOL)connectToServer:(NSString*)host onPort:(int)portNum;
-(void)loadCertificate:(NSURL*)privateKey;
-(void)loadCA:(NSURL*)certificate;
-(BOOL)openSSLConnection;
-(void)closeConnection;

@end

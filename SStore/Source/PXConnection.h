//
//  PXConnection.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

/*
 *	This in an abstract class that mainly handles the SSL
 *	details for the subclasses
 */

#import <Cocoa/Cocoa.h>
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

@interface PXConnection : NSObject{
@private
	//Socket members
	int mainSocket;
	int port
	
	//SSL members
	SSL_METHOD *sslMethod;
	SSL_CTX *sslContext;
	SSL *sslConnection;
	BIO *bioConnection;
	NSString *pemPassword;
	
	//Status Members
	id<PXConnectionDelegate> delegate;
	BOOL connected;
	BOOL secure;
}
//Socket properties
@property (readwrite, nonatomic) int mainSocket;
@property (readwrite, nonatomic) int port;

//SSL properties
@property (readwrite, nonatomic) SSL_METHOD *sslMethod;
@property (readwrite, nonatomic) SSL_CTX *sslContext;
@property (readwrite, nonatomic) SSL *sslConnection;
@property (readwrite, nonatomic) BIO *bioConnection;
@property (readwrite, nonatomic, retain) NSString *pemPassword;

//Status properties
@property (readwrite, nonatomic, assign) id<PXConnectionDelegate> delegate;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;
@property (readonly, nonatomic, getter=isSecure) BOOL secure;

//Data Management
-(void)send:(NSData *)data; //Abstract
-(void)setRecieve; //Abstract

//SSL Management
-(void)loadKey:(NSURL*)privateKey withPassword:(NSString*)password;
-(void)loadCA:(NSURL*)certificate;
-(void)prepareSSLConnection;
-(BOOL)openSSLConnection; //Abstract

@end

//
//  PXServer.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXConnection.h"

@interface PXServer : PXConnection {
@private
	//Extra listening socket
	int listeningSocket;
	NSThread *incomingListenThread;
	BOOL lookingForConnection;

}
@property (readwrite, nonatomic) int listeningSocket;
@property (readwrite) BOOL lookingForConnection;

-(BOOL)openSocket;
-(void)closeSocket;
-(BOOL)checkConnection;
-(void)openConnection;
-(void)send:(NSData *)data;
-(void)listen;
-(void)listenForConnections;

//SSL fun
-(BOOL)openSSLConnection;

@end

//
//  PXClient.h
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXConnection.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

@interface PXClient : NSObject<PXConnection> {
@private
	int port;
	id<PXConnectionDelegate> delegate;
    BOOL connected;
	int socketConnection;
}

@property (readwrite, nonatomic) int port;
@property (readwrite, nonatomic, assign) id<PXConnectionDelegate> delegate;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

-(BOOL)connectToServer:(NSString*)host onPort:(int)portNum;
-(void)closeConnection;

@end

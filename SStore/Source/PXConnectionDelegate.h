//
//  PXConnectionDelegaet.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXConnection.h"

@protocol PXConnection;

@protocol PXConnectionDelegate <NSObject>
-(void)recievedData:(NSData *)data fromConnection:(id<PXConnection>)connection;
@end

//
//  PXConnectionDelegaet.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXConnection.h"

@class PXConnection;

@protocol PXConnectionDelegate <NSObject>
-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection;
@end

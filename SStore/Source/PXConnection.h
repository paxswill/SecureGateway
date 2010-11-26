//
//  PXConnection.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXConnectionDelegate.h"

@protocol PXConnection <NSObject>

@property (readwrite, nonatomic) int port;
@property (readwrite, nonatomic, assign) id<PXConnectionDelegate> delegate;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;

-(void)send:(NSData *)data;


@end

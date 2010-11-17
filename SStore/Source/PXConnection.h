//
//  PXConnection.h
//  SStore
//
//  Created by Will Ross on 11/16/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXConnectionDelegate.h"

@protocol PXConnection <NSObject>

@property (readwrite, nonatomic) int port;
@property (readwrite, nonatomic) NSHost *host;
@property (readwrite, nonatomic) id<PXConnectionDelegate> delegate;

-(void)send:(NSData *)data;


@end

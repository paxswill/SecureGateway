//
//  PXMultiServer.h
//  AppGate
//
//  Created by Will Ross on 12/3/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXServer.h"

@interface PXMultiServer : PXServer {
@private
    NSMutableDictionary *fd2ip, *ip2fd;
}

@property (readwrite, retain) NSMutableDictionary *fd2ip, *ip2fd;

-(void)openConnection;

@end

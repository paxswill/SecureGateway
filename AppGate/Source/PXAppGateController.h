//
//  PXAppGateController.h
//  AppGate
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXClient.h"
#import "PXConnectionDelegate.h"

@interface PXAppGateController : NSObject<PXConnectionDelegate> {
@private
    PXClient *client;
	NSMutableDictionary *authenticatedUsers;
}
@property (readwrite, nonatomic, retain) PXClient *client;
@property (readwrite, nonatomic, retain) NSMutableDictionary *authenticatedUsers;

-(id)initWithConfiguration:(NSDictionary *)configDict;
-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection;
-(void)processSStoreCommand:(NSString *)cmd;

@end

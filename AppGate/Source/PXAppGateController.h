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
#import <openssl/md5.h>
#import "NSData+HexString.h"

@interface PXAppGateController : NSObject<PXConnectionDelegate> {
@private
    PXClient *client;
	NSMutableDictionary *transactions;
	NSMutableDictionary *users;
	unsigned int transactionCounter;
}
@property (readwrite, nonatomic, retain) PXClient *client;
@property (readwrite, nonatomic, retain) NSMutableDictionary *transactions;
@property (readwrite, nonatomic, retain) NSMutableDictionary *users;
@property (readonly, nonatomic) unsigned int transactionCounter;

-(unsigned int)incrementTransactions;

-(id)initWithConfiguration:(NSDictionary *)configDict;
-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection;
-(void)processSStoreCommand:(NSString *)cmd;

@end

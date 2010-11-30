//
//  PXSStoreController.h
//  SStore
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXServer.h"
#import "PXSQLiteRecords.h"

@interface PXSStoreController : NSObject {
@private
    PXServer *server;
	PXSQLiteRecords *storage;
	
	//SSL Config data
	NSURL *certURL;
	NSURL *keyURL;
	NSString *keyPassword;
}
-(id)initWithConfiguration:(NSDictionary *)config;



@end

//
//  PXSStoreController.h
//  SStore
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXConnectionDelegate.h"
#import "PXServer.h"
#import "PXSQLiteRecords.h"
#import "NSData+HexString.h"
//The model Objects
#import "PXPerson.h"
#import "PXStudent.h"
#import "PXFaculty.h"
#import "PXCourse.h"
#import "PXDocument.h"

@interface PXSStoreController : NSObject<PXConnectionDelegate> {
@private
    PXServer *server;
	PXSQLiteRecords *storage;
	
	//SSL Config data
	NSURL *certURL;
	NSURL *keyURL;
	NSString *keyPassword;
}
@property (readwrite, nonatomic, retain) PXServer *server;


-(id)initWithConfiguration:(NSDictionary *)config;
-(void)jumpToSecure;
-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection;
-(void)processAppGateCommand:(NSString *)cmd;

-(BOOL)authenticateUser:(NSString *)email withPasswordHash:(NSData *)hash;
-(PXPerson *)personWithEmail:(NSString *)email;
@end

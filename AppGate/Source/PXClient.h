//
//  PXClient.h
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXConnection.h"

@interface PXClient : PXConnection {
@private
	
}

-(BOOL)connectToServer:(NSString*)host onPort:(int)portNum;
-(void)closeConnection;

@end

//
//  main.m
//  AppGate
//
//  Created by Will Ross on 11/26/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXClient.h"

int main (int argc, const char * argv[]) {

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//test the client
	PXClient *testClient = [[PXClient alloc] init];
	if(![testClient connectToServer:@"127.0.0.1" onPort:6968]){
		NSLog(@"Connection failed");
	}else{
		NSLog(@"Connection succeeded!");
	}
	[testClient prepareSSL];
	[testClient loadCA:[NSURL URLWithString:@"file:///Users/paxswill/Developer/School/CS472/SecureGateway/demoCA/cacert.pem"]];
	[testClient loadCertificate:[NSURL URLWithString:@"/Users/paxswill/Developer/School/CS472/SecureGateway/AppGate Certs/newkey.pem"]];
	[testClient openSSLConnection];
	
	[testClient closeConnection];

	[pool drain];
    return 0;
}


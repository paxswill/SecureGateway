//
//  PXAppGateController.m
//  AppGate
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXAppGateController.h"

@interface PXAppGateController()
@property (readwrite, nonatomic) unsigned int transactionCounter;
@end

@implementation PXAppGateController

@synthesize client;
@synthesize transactions;
@synthesize transactionCounter;
@synthesize users;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
		transactions = [[NSMutableDictionary alloc] init];
		transactionCounter = 1;
		users = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(id)initWithConfiguration:(NSDictionary *)configDict{
	if((self = [self init])){
		//Load the config options
		NSString *host = [configDict objectForKey:@"storeHost"];
		int port = [[configDict objectForKey:@"portNumber"] intValue];
		NSURL *certURL = [NSURL URLWithString:[configDict objectForKey:@"certificateFile"]];
		NSURL *keyURL = [NSURL URLWithString:[configDict objectForKey:@"keyFile"]];
		NSString *keyPassword = [configDict objectForKey:@"keyPassword"];
		
		//Load the client up
		self.client = [[PXClient alloc] init];
		self.client.delegate = self;
		if(![client connectToServer:host onPort:port]){
			NSLog(@"Connection failed");
			return nil;
		}else{
			NSLog(@"Connection succeeded!");
		}
		
		[self.client listen];
		
		[self.client prepareSSLConnection];
		[self.client loadCertChain:certURL];
		[self.client loadKey:keyURL withPassword:keyPassword];
	}
	return self;
}

- (void)dealloc {
    // Clean-up code here.
    [client closeConnection];
    [super dealloc];
}

-(unsigned int)incrementTransactions{
	self.transactionCounter = (self.transactionCounter == UINT_MAX) ? 0 : self.transactionCounter + 1;
	return self.transactionCounter;
}

-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection{
	NSString *recievedString = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSLog(@"Recieved%@:\n%@", (self.client.secure ? @" securely": @""), recievedString);
	[self processSStoreCommand:recievedString];
	[recievedString release];
}

-(void)processSStoreCommand:(NSString *)cmd{
	NSArray *cmdComponents = [cmd componentsSeparatedByString:@" "];
	NSString *keyWord = [[cmdComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	if([keyWord isEqualToString:@"goSecure"]){
		//Acknowledge
		[self.client sendString:@"goSecure"];
		//Switch up to SSL
		[self.client openSSLConnection];
	}else if([keyWord isEqualToString:@"login"]){
		/*
		 login <email> <PW>
		 */
		//Time to authenticate
		//Make a transaction
		[self.transactions setObject:[NSNumber numberWithInt:[self incrementTransactions]] 
							  forKey:[NSNumber numberWithInt:self.client.mainSocket]];
		//Hash the PW
		NSData *hash = [NSData dataWithBytes:MD5((const unsigned char *)[[cmdComponents objectAtIndex:2] UTF8String], [[cmdComponents objectAtIndex:2] length] + 1, NULL) length:MD5_DIGEST_LENGTH];
		//Send off the request
		[self.client sendString:[NSString stringWithFormat:@"authenticate %d %@ %@", self.transactionCounter, [cmdComponents objectAtIndex:1], [hash hexString]]];
	}else if([keyWord isEqualToString:@"authenticated"]){
		/*
		 authenticated <IDNum> <email>
		 */
		if([cmdComponents count] == 2){
			//Auth failure
			NSLog(@"Login failed");
		}else{
			//login sucessful
			NSLog(@"Login successful");
			[self.users setValue:[NSNumber numberWithInt:self.client.mainSocket] forKey:[cmdComponents objectAtIndex:3]];
		}
	}else if([keyWord isEqualToString:@"add"]){
		/*
		 addUser <email> <password> 
		 */
	}
}


@end

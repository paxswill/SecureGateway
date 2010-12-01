//
//  PXSStoreController.m
//  SStore
//
//  Created by Will Ross on 11/29/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "PXSStoreController.h"


@implementation PXSStoreController

@synthesize server;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithConfiguration:(NSDictionary *)config{
	if((self = [self init])){
		//Get the config parameters
		int port = [[config objectForKey:@"portNumber"] intValue];
		certURL = [NSURL URLWithString:[config objectForKey:@"certificateFile"]];
		keyURL = [NSURL URLWithString:[config objectForKey:@"keyFile"]];
		keyPassword = [config objectForKey:@"keyPassword"];
		NSString *dbFile = [config objectForKey:@"dbFile"];
		NSString *dbPassword = [config objectForKey:@"dbPassword"];
		
		//Make the server
		//Create the server
		server = [[PXServer alloc] init];
		server.port = port;
		server.delegate = self;
		if(![server openSocket]){
			NSLog(@"Fatal error in opening socket. Try re-running the program");
			return nil;
		}
		[server listenForConnections];
		
		//Open the store
		storage = [[PXSQLiteRecords alloc] initDatabaseAtLocation:dbFile withPassword:dbPassword];
	}
	return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

-(void)jumpToSecure{
	[self.server sendString:@"goSecure"];
}

-(void)recievedData:(NSData *)data fromConnection:(PXConnection *)connection{
	if(data == nil && connection == nil){
		//This si the signal that The server is now listening
		
	}
	NSString *recievedString = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSLog(@"Recieved%@:\n%@", (self.server.secure ? @" securely": @""), recievedString);
	[self processAppGateCommand:recievedString];
	[recievedString release];
}

-(void)processAppGateCommand:(NSString *)cmd{
	NSArray *cmdComponents = [cmd componentsSeparatedByString:@" "];
	NSString *keyWord = [cmdComponents objectAtIndex:0];
	if([keyWord isEqualToString:@"goSecure"]){
		//Acknowledge
		//Set up SSL
		[server loadCertChain:certURL];
		[server loadKey:keyURL withPassword:keyPassword];
		[server prepareSSLConnection];
		//Switch up to SSL
		[server openSSLConnection];
	}else if([keyWord isEqualToString:@"retrieve"]){
		//Object retrieval
		/*
		 *** Request Form ***
		 retrieve <RequestNumber> <Type> <SearchProperty> <SearchValue>
		 <RequestNumber> is of use to the AppGate only, it serves to keep track of transactions
		 <Type> is the type of object to get: Person, Faculty, Student, Course, Document
		 <SearchProperty> is the name of the title of the key to search
		 <SearchValue> is the value to search for
		 *** Return Form ***
		 object <RequestNumber> <HexData>
		 */
	}else if([keyWord isEqualToString:@"authenticate"]){
		/*
		 *** Request ***
		 authenticate <RequestNumber> <Email> <PWHash>
		 *** Return ***
		 authenticated <RequestNumber> [YES|NO]
		 */
		NSMutableSet *allPersons = [[NSMutableSet alloc] init];
		[allPersons unionSet:[storage objectsOfType:[PXPerson class] forKey:@"email" value:[cmdComponents objectAtIndex:2]]];
		[allPersons unionSet:[storage objectsOfType:[PXFaculty class] forKey:@"email" value:[cmdComponents objectAtIndex:2]]];
		[allPersons unionSet:[storage objectsOfType:[PXStudent class] forKey:@"email" value:[cmdComponents objectAtIndex:2]]];
		//Behaviour is undefined if more than one person shares an email
		PXPerson *person = [[allPersons anyObject] retain];
		[allPersons release];
		NSData *recievedHash = [NSData dataWithHexString:[cmdComponents objectAtIndex:3]];
		NSString *response = [NSString stringWithFormat:@"authenticated %@ %@",
							  [cmdComponents objectAtIndex:1],
							  ([person.pwHash isEqualToData:recievedHash] ? @"YES" : @"NO")];
		//Send the response back
		[self.server sendString:response];
	}else if([keyWord isEqualToString:@"reset"]){
		/*
		 *** Request ***
		 reset <RequestNumber> <Email1> <Email2> <PWHash>
		 <Email1> is the account to reset
		 <Email2> is an admin account
		 <PWHash> is the hash of the admin
		 *** Return ***
		 reset <RequestNumber> <NewPW>
		 <NewPW> is the plainText of the new password. It is randomly generated.
		 */
	}else if([keyWord isEqualToString:@"addUser"]){
		/*
		 *** Request ***
		 addUser <RequestNumber> <Email> <PWHash> <Type> [AdminEmail] [AdminPWHash]
		 <Email> is the email to add
		 <Type> is either Faculty, Student, or Admin
		 [AdminEmail] and [AdminPWHash] are optional, but if provided (and they match an admin) the new User is created as an admin
		 *** Return ***
		 addUser <RequestNumber> <idNumber>
		 This is just confirming that it's done
		 */
	}else if([keyWord isEqualToString:@"addDocument"]){
		/*
		 *** Request ***
		 addDocument <RequestNumber> <Owner> <DocName> <DocHex>
		 *** Response ***
		 addDocument <RequestNumber> <idNumber>
		 */
	}else if([keyWord isEqualToString:@"addDocumentAccess"]){
		/*
		 *** Request ***
		 addDocumentAccess <RequestNumber> <DocNumber> [CourseNumber|IDNumber]
		 *** Response ***
		 addDocumentAccess <RequestNumber>
		 */
	}else if([keyWord isEqualToString:@"addCourse"]){
		/*
		 *** Request ***
		 addCourse <RequestNumber> <TeacherID>
		 *** Response ***
		 addCourse <RequestNumber> <idNumber>
		 */
	}else if([keyWord isEqualToString:@"addCourseAccess"]){
		/*
		 *** Request ***
		 addCourseAccess <RequestNumber> <CourseNumber> <StudentID>
		 *** Response ***
		 addCourseAccess <RequestNumber>
		 */
	}else if([keyWord isEqualToString:@"getAll"]){
		/*
		 *** Request getAll**
		 addDocumentAccess <RequestNumber> <Type>
		 *** Response ***
		 getAll <RequestNumber> <Hex>
		 <Hex> is an encoded NSArray of the items
		 */
	}
}

@end

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
		//What kind of class are we getting?
		Class typeClass;
		NSString *typeString = [cmdComponents objectAtIndex:2];
		if([typeString isEqualToString:@"Person"]){
			typeClass = [PXPerson class];
		}else if([typeString isEqualToString:@"Faculty"]){
			typeClass = [PXFaculty class];
		}else if([typeString isEqualToString:@"Student"]){
			typeClass = [PXStudent class];
		}else if([typeString isEqualToString:@"Course"]){
			typeClass = [PXCourse class];
		}else if([typeString isEqualToString:@"Document"]){
			typeClass = [PXDocument class];
		}
		//Get it
		id obj = [[storage objectsOfType:typeClass forKey:[cmdComponents objectAtIndex:3] value:[cmdComponents objectAtIndex:4]] anyObject];
		//Send it back
		NSData *objData = [NSKeyedArchiver archivedDataWithRootObject:obj];
		[self.server sendString:[NSString stringWithFormat:@"object %@ %@", [cmdComponents objectAtIndex:1], [objData hexString]]];
	}else if([keyWord isEqualToString:@"authenticate"]){
		/*
		 *** Request ***
		 authenticate <RequestNumber> <Email> <PWHash>
		 *** Return ***
		 authenticated <RequestNumber> <email>
		 or 
		 authenticated <RequestNumber>
		 The second form is for failure
		 */
		NSData *recievedHash = [NSData dataWithHexString:[cmdComponents objectAtIndex:3]];
		BOOL authenticated = [self authenticateUser:[cmdComponents objectAtIndex:2] withPasswordHash:recievedHash];
		if(authenticated){
			NSString *response = [NSString stringWithFormat:@"authenticated %@ %@",
								  [cmdComponents objectAtIndex:1],
								  [cmdComponents objectAtIndex:2]];
			//Send the response back
			[self.server sendString:response];
		}else{
			NSString *response = [NSString stringWithFormat:@"authenticated %@",
								  [cmdComponents objectAtIndex:1]];
			//Send the response back
			[self.server sendString:response];
		}
	}else if([keyWord isEqualToString:@"reset"]){
		/*
		 *** Request ***
		 reset <RequestNumber> <Email> <PWHash> <AdminEmail> <AdminPWHash>
		 <Email1> is the account to reset
		 <Email2> is an admin account
		 <PWHash> is the hash of the admin
		 *** Return ***
		 reset <RequestNumber> [YES|NO]
		 */
		NSData *recievedHash = [NSData dataWithHexString:[cmdComponents objectAtIndex:5]];
		BOOL adminAuth = [self authenticateAdmin:[cmdComponents objectAtIndex:5] withPasswordHash:recievedHash];
		NSString *response;
		if(adminAuth){
			//Admin authenticated
			PXPerson *forgetful = [self personWithEmail:[cmdComponents objectAtIndex:2]];
			forgetful.pwHash = [NSData dataWithHexString:[cmdComponents objectAtIndex:3]];
			[storage save:forgetful];
			response = [NSString stringWithFormat:@"reset %@ YES", [cmdComponents objectAtIndex:1]];
		}else{
			response = [NSString stringWithFormat:@"reset %@ NO", [cmdComponents objectAtIndex:1]];
		}
		[self.server sendString:response];
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
		PXCourse *newCourse = [[PXCourse alloc] init];
		newCourse.instructor = [self facultyWithID:[[cmdComponents objectAtIndex:2] intValue]];
		[storage save:newCourse];
		[self.server sendString:[NSString stringWithFormat:@"addCourse %@ %d", [cmdComponents objectAtIndex:1], newCourse.idNumber]];
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
		 getAll <RequestNumber> <Type>
		 *** Response ***
		 getAll <RequestNumber> <Hex>
		 <Hex> is an encoded NSSet of the items
		 */
		Class typeClass;
		NSString *typeString = [cmdComponents objectAtIndex:2];
		if([typeString isEqualToString:@"Person"]){
			typeClass = [PXPerson class];
		}else if([typeString isEqualToString:@"Faculty"]){
			typeClass = [PXFaculty class];
		}else if([typeString isEqualToString:@"Student"]){
			typeClass = [PXStudent class];
		}else if([typeString isEqualToString:@"Course"]){
			typeClass = [PXCourse class];
		}else if([typeString isEqualToString:@"Document"]){
			typeClass = [PXDocument class];
		}
		NSSet *objects = [storage objectsOfType:typeClass forKey:nil value:nil];
		NSString *hexData = [[NSKeyedArchiver archivedDataWithRootObject:objects] hexString];
		//Send it off
		[self.server sendString:[NSString stringWithFormat:@"getAll %@ %@", [cmdComponents objectAtIndex:1], hexData]];
	}else if([keyWord isEqualToString:@"save"]){
		/*
		 *** Request ***
		 save <RequestNumber> <Hex>
		 *** Response ***
		 saved <RequestNumber>
		 */
		NSData *hexData = [NSData dataWithHexString:[cmdComponents objectAtIndex:2]];
		PXSQLiteObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:hexData];
		[storage save:obj];
		[self.server sendString:[NSString stringWithFormat:@"addCourse %@", [cmdComponents objectAtIndex:1]]];
	}
}

-(BOOL)authenticateUser:(NSString *)email withPasswordHash:(NSData *)hash{
	PXPerson *person = [self personWithEmail:email];
	return [person.pwHash isEqualToData:hash];
}

-(BOOL)authenticateAdmin:(NSString *)email withPasswordHash:(NSData *)hash{
	PXPerson *person = [self personWithEmail:email];
	return [person.pwHash isEqualToData:hash] && person.admin;
}

-(PXPerson *)personWithEmail:(NSString *)email{
	NSMutableSet *allPersons = [[NSMutableSet alloc] init];
	[allPersons unionSet:[storage objectsOfType:[PXPerson class] forKey:@"email" value:email]];
	[allPersons unionSet:[storage objectsOfType:[PXFaculty class] forKey:@"email" value:email]];
	[allPersons unionSet:[storage objectsOfType:[PXStudent class] forKey:@"email" value:email]];
	//Behaviour is undefined if more than one person shares an email
	PXPerson *person = [[allPersons anyObject] retain];
	[allPersons release];
	return [person autorelease];
}

-(PXPerson *)personWithID:(int)idNum{
	NSMutableSet *allPersons = [[NSMutableSet alloc] init];
	[allPersons unionSet:[storage objectsOfType:[PXPerson class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]]];
	[allPersons unionSet:[storage objectsOfType:[PXFaculty class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]]];
	[allPersons unionSet:[storage objectsOfType:[PXStudent class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]]];
	//Behaviour is undefined if more than one person shares an idNumber
	PXPerson *person = [[allPersons anyObject] retain];
	[allPersons release];
	return [person autorelease];
}

-(PXStudent *)studentWithID:(int)idNum{
	NSSet *students = [storage objectsOfType:[PXStudent class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]];
	return [students anyObject];
}

-(PXFaculty *)facultyWithID:(int)idNum{
	NSSet *faculty = [storage objectsOfType:[PXFaculty class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]];
	return [faculty anyObject];
}

-(PXCourse *)courseWithID:(int)idNum{
	NSSet *courses = [storage objectsOfType:[PXCourse class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]];
	return [courses anyObject];
}

-(PXDocument *)documentWithID:(int)idNum{
	NSSet *documents = [storage objectsOfType:[PXDocument class] forKey:@"idNumber" value:[NSNumber numberWithInt:idNum]];
	return [documents anyObject];
}

@end

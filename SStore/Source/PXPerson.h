//
//  PXPerson.h
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXSQLiteObject.h"

@interface PXPerson : PXSQLiteObject {
@protected
	NSString *name;
	BOOL admin;
	NSString *email;
	NSData *pwHash;
}
@property (readwrite, nonatomic, retain) NSString *name;
@property (readwrite, nonatomic, retain) NSString *email;
@property (readwrite, nonatomic) BOOL admin;
@property (readwrite, nonatomic, retain) NSData *pwHash;

-(id)initPersonWithName:(NSString *)name andPasswordHash:(NSData *)hash;
-(NSSet *)getDocuments;

@end

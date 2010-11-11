//
//  PXPerson.h
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXPerson : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * idNumber;
@property (nonatomic, retain) NSNumber * admin;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * passwordHash;
@property (nonatomic, retain) NSSet* availableDocuments;

@end

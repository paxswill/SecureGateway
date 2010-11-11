//
//  PXDocument.h
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXDocument : NSManagedObject {
@private
}
@property (nonatomic, retain) NSData * documentData;
@property (nonatomic, retain) NSString * documentPath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) PXFaculty * owner;
@property (nonatomic, retain) NSSet* allowedPersons;
@property (nonatomic, retain) NSSet* allowedCourses;

@end

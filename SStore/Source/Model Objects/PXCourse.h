//
//  PXCourse.h
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXCourse : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * idNumber;
@property (nonatomic, retain) PXFaculty * instructor;
@property (nonatomic, retain) NSSet * enrolledStudents;
@property (nonatomic, retain) NSSet * courseDocuments; 

@end

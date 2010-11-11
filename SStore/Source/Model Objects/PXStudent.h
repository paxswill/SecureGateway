//
//  PXStudent.h
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXStudent : NSManagedObject {
@private
}
@property (nonatomic, retain) PXCourse * enrolledCourses;

@end

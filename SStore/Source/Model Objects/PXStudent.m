//
//  PXStudent.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import "PXStudent.h"


@implementation PXStudent
@dynamic enrolledCourses;


-(NSSet*)availableDocuments{
	NSMutableSet *allDocs = [[NSMutableSet alloc] init];
	//Start by getting the docs set to just this Person
	[self willAccessValueForKey:@"availableDocuments"];
	[allDocs unionSet:[self primitiveAvailableDocuments]];
	[self didAccessValueForKey"@availableDocuments"];
	//Loop through all courses, grabbing documents assigned for those classes
	for(PXCourse *course in self.enrolledCourses){
		[allDocs unionSet:course.courseDocuments];
	}
	return [allDocs autorelease];
}

@end

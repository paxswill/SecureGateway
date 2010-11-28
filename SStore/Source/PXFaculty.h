//
//  PXFaculty.h
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXPerson.h"

@interface PXFaculty : PXPerson {
@private
    NSMutableSet *classes;
	NSMutableSet *documents;
}
@property (readwrite, nonatomic, retain) NSMutableSet *classes;
@property (readwrite, nonatomic, retain) NSMutableSet *documents;



@end

//
//  PXFaculty.h
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 Naval Research Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXFaculty : NSManagedObject {
@private
}
@property (nonatomic, retain) NSSet* coursesTaught;
@property (nonatomic, retain) PXDocument * documentsOwned;

@end

//
//  SecureSchoolAppDelegate.h
//  SecureSchool
//
//  Created by Will Ross on 11/30/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SecureSchoolAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end

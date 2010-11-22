//
//  main.m
//  SStore
//
//  Created by Will Ross on 11/10/10.
//  Copyright (c) 2010 William Ross. All rights reserved.
//

#import <objc/objc-auto.h>


#import "PXServer.h"

NSManagedObjectModel *managedObjectModel();
NSManagedObjectContext *managedObjectContext();

int main (int argc, const char * argv[]) {
	
	objc_startCollectorThread();
	
	// Create the managed object context
	NSManagedObjectContext *context = managedObjectContext();
	
	//Testing:
	//Start a server
	PXServer *testServer = [[PXServer alloc] init];
	if(![testServer openSocket]){
		NSLog(@"Fatal error in opening socket. Try re-running the program");
		return 1;
	}

	//Run the run loop in 0.5 second intervals
	for(int loopStatus; loopStatus != kCFRunLoopRunFinished && loopStatus != kCFRunLoopRunStopped && loopStatus != kCFRunLoopRunHandledSource && ![testServer isConnected];){
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		NSLog(@"Run loop popped out.");
	}
	
	// Save the managed object context
	NSError *error = nil;    
	if (![context save:&error]) {
		NSLog(@"Error while saving\n%@",
			  ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
		exit(1);
	}
    return 0;
}

NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel *model = nil;
    
    if (model != nil) {
        return model;
    }
    
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
	path = [path stringByDeletingPathExtension];
	NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"mom"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}
NSManagedObjectContext *managedObjectContext() {
	
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
    [context setPersistentStoreCoordinator: coordinator];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;
	
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
	path = [path stringByDeletingPathExtension];
	NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
    
	NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    return context;
}


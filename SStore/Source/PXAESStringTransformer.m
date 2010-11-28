//
//  PXAESStringTransformer.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXAESStringTransformer.h"


@implementation PXAESStringTransformer

- (id)initWithKey:(NSString *)keyString {
    if ((self = [super init])) {
        //Everything important is done in super
    }
    
    return self;
}

- (void)dealloc {
    //Again, everything in super
    [super dealloc];
}

+(BOOL)allowsReverseTransformation{
	return YES;
}

+(Class)transformedValueClass{
	return [NSData class];
}

-(id)transformedValue:(NSString *)value{
	[cryptor setClearTextWithString:value];
	return [cryptor encrypt:@"aes256"];
}

-(NSString *)reverseTransformedValue:(id)value{
	[cryptor setCipherText:value];
	[cryptor decrypt:@"aes256"];
	return [cryptor clearTextAsString];
}

@end

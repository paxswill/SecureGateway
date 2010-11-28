//
//  PXAESTransformer.m
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import "PXAESDataTransformer.h"

@implementation PXAESDataTransformer

- (id)initWithKey:(NSString *)keyString {
    if ((self = [super init])) {
        NSData *keyData = [SSCrypto getKeyDataWithLength:64 fromPassword:keyString withSalt:@"CS472"];
		cryptor = [[[SSCrypto alloc] initWithSymmetricKey:keyData] retain];
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [cryptor release];
    [super dealloc];
}

+(BOOL)allowsReverseTransformation{
	return YES;
}

+(Class)transformedValueClass{
	return [NSData class];
}

-(id)transformedValue:(id)value{
	[cryptor setClearTextWithData:value];
	return [cryptor encrypt:@"aes256"];
}

-(id)reverseTransformedValue:(id)value{
	[cryptor setCipherText:value];
	return [cryptor decrypt:@"aes256"];
}

@end

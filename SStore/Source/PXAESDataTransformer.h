//
//  PXAESTransformer.h
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSCrypto.h"

@interface PXAESDataTransformer : NSValueTransformer {
@protected
	SSCrypto *cryptor;
}

+(BOOL)allowsReverseTransformation;
+(Class)transformedValueClass;
-(id)transformedValue:(id)value;
-(id)reverseTransformedValue:(id)value;

@end

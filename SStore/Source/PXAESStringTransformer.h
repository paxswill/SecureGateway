//
//  PXAESStringTransformer.h
//  SStore
//
//  Created by Will Ross on 11/28/10.
//  Copyright 2010 Naval Research Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXAESDataTransformer.h"

@interface PXAESStringTransformer : PXAESDataTransformer {
@private
    
}

+(BOOL)allowsReverseTransformation;
+(Class)transformedValueClass;
-(id)transformedValue:(NSString *)value;
-(NSString *)reverseTransformedValue:(id)value;

@end

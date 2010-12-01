//
//  NSData+HexString.h
//  SStore
//
//  Created by Will Ross on 11/30/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (HexString)

-(NSString *)hexString;
+(NSData *)dataWithHexString:(NSString *)hex;

+(int)valueForHexCharacter:(unichar)c;

@end

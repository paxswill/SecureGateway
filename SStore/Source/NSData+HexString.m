//
//  NSData+HexString.m
//  SStore
//
//  Created by Will Ross on 11/30/10.
//  Copyright 2010 Will Ross. All rights reserved.
//

#import "NSData+HexString.h"


@implementation NSData (HexString)

-(NSString *)hexString{
	NSString *hexString = [self description];
	hexString = [hexString stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hexString = [hexString stringByReplacingOccurrencesOfString:@">" withString:@""];
	hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
	return hexString;
}

+(NSData *)dataWithHexString:(NSString *)hex{
	NSMutableData *newData = [[NSMutableData alloc] initWithLength:([hex length] / 2)];
	for(int i = 0; i < [hex length]; i += 2){
		uint8_t byte = 0;
		//Get the upper nibble
		byte += [NSData valueForHexCharacter:[hex characterAtIndex:i]];
		byte <<= 4;
		//And now the lower nibble
		byte += [NSData valueForHexCharacter:[hex characterAtIndex:(i + 1)]];
		[newData appendBytes:&byte length:1];
	}
	return [newData autorelease];
}
	

+(int)valueForHexCharacter:(unichar)c{
	switch(c){
		case '0':
		default:
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		case 'A':
		case 'a':
			return 10;
		case 'B':
		case 'b':
			return 11;
		case 'C':
		case 'c':
			return 12;
		case 'D':
		case 'd':
			return 13;
		case 'E':
		case 'e':
			return 14;
		case 'F':
		case 'f':
			return 15;
	}
}

@end

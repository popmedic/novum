//
//  NSString+Random.m
//  NovumField
//
//  Created by Kevin Scardina on 4/21/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)
+ (NSString *)randomStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}
@end

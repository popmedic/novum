//
//  NVMBaseUsers.h
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/16/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVMBaseUsers : NSObject
{
    NSString* user;
    NSString* password;
    NSString* getMsgHeadersURL;
}

@property (copy, nonatomic) NSString *user;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *loginURL;
@property (copy, nonatomic) NSString *getMsgHeadersURL;
@property (copy, nonatomic) NSString *getAtchHeadersURL;
@property (copy, nonatomic) NSString *getAtchFileURLFmt;

- (void) save;
- (void) login:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
- (void) getMsgHeaders:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
- (void) getMsgHeadersStart:(NSDate*)start
                        End:(NSDate*)end
                    Handler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
- (void) getAtchHeaders:(NSString*)msgId
                Handler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
- (NSURL*) getAtchFileURL:(NSString*)atchId
                    Thumb:(BOOL) thumb;
@end

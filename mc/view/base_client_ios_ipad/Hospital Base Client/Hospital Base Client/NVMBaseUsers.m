//
//  NVMBaseUsers.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/16/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMBaseUsers.h"

@implementation NVMBaseUsers

@synthesize user;
@synthesize password;
@synthesize getMsgHeadersURL;

- (id) init {
    
    self = [super init];
    if (self) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"mc.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"mc" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!temp) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, (int)format);
        }
        self.user = [temp objectForKey:@"user"];
        self.password = [temp objectForKey:@"password"];
        self.getMsgHeadersURL = [temp objectForKey:@"getMsgHeadersURL"];
        self.loginURL = [temp objectForKey:@"loginURL"];
        self.getAtchHeadersURL = [temp objectForKey:@"getAtchHeadersURL"];
        self.getAtchFileURLFmt = [temp objectForKey:@"getAtchFileURLFmt"];
    }
    return self;
}

- (void) save {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: user, password, getMsgHeadersURL, nil]
                                                          forKeys:[NSArray arrayWithObjects: @"user", @"password", getMsgHeadersURL, nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"%@", error.description);
    }
}

- (void) login:(void (^)(NSURLResponse*, NSData*, NSError*))handler{
    NSError* error;
    
    NSMutableDictionary *dvars = [[NSMutableDictionary alloc] init];
    [dvars setValue:self.user forKey:@"name"];
    [dvars setValue:self.password forKey:@"password"];
    
    NSURL *url = [NSURL URLWithString:self.loginURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    request.HTTPMethod = @"POST";
    
    NSString* jsonVars = @"";
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dvars options:1 error:&error];
    if(jsonData != nil){
        jsonVars = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", jsonVars);
    }
    request.HTTPBody = [[NSString stringWithFormat:@"vars=%@", jsonVars] dataUsingEncoding: NSASCIIStringEncoding];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:handler];
}

- (void) getMsgHeadersStart:(NSDate*)start
                        End:(NSDate*)end
                    Handler:(void (^)(NSURLResponse*, NSData*, NSError*))handler{
    NSError* error;
    
    NSMutableDictionary *dvars = [[NSMutableDictionary alloc] init];
    [dvars setValue:self.user forKey:@"name"];
    [dvars setValue:self.password forKey:@"password"];
    if(start != nil){
        [dvars setValue:start.description forKey:@"start"];
    }
    if(end != nil){
        [dvars setValue:end.description forKey:@"end"];
    }
    
    NSURL *url = [NSURL URLWithString:self.getMsgHeadersURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    request.HTTPMethod = @"POST";
    
    NSString* jsonVars = @"";
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dvars options:1 error:&error];
    if(jsonData != nil){
        jsonVars = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", jsonVars);
    }
    request.HTTPBody = [[NSString stringWithFormat:@"vars=%@", jsonVars] dataUsingEncoding: NSASCIIStringEncoding];

    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:handler];
}

- (void) getMsgHeaders:(void (^)(NSURLResponse*, NSData*, NSError*))handler{
    [self getMsgHeadersStart:nil End:nil Handler:handler];
}

- (void) getAtchHeaders:(NSString*)msgId
                Handler:(void (^)(NSURLResponse*, NSData*, NSError*))handler{
    NSError* error;
    
    NSMutableDictionary *dvars = [[NSMutableDictionary alloc] init];
    [dvars setValue:self.user forKey:@"name"];
    [dvars setValue:self.password forKey:@"password"];
    [dvars setValue:msgId forKey:@"message_id"];
    
    NSURL *url = [NSURL URLWithString:self.getAtchHeadersURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    request.HTTPMethod = @"POST";
    
    NSString* jsonVars = @"";
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dvars options:1 error:&error];
    if(jsonData != nil){
        jsonVars = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
       // NSLog(@"%@", jsonVars);
    }
    request.HTTPBody = [[NSString stringWithFormat:@"vars=%@", jsonVars] dataUsingEncoding: NSASCIIStringEncoding];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:handler];
}

- (NSURL*) getAtchFileURL:(NSString*)atchId
                    Thumb:(BOOL) thumb{
    NSError* error;
    
    NSMutableDictionary *dvars = [[NSMutableDictionary alloc] init];
    [dvars setValue:self.user forKey:@"name"];
    [dvars setValue:self.password forKey:@"password"];
    [dvars setValue:atchId forKey:@"id"];
    if(thumb) [dvars setValue:@"YES" forKey:@"thumb"];
    
    NSString* jsonVars = @"";
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dvars options:1 error:&error];
    if(jsonData != nil){
        jsonVars = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", jsonVars);
    }
    NSString* urlstr = [NSString stringWithFormat:self.getAtchFileURLFmt, [[jsonVars stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
   // NSLog(@"%@", urlstr);
   return [NSURL URLWithString:urlstr];
}

@end

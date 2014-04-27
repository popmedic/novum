//
//  NVMFieldUser.m
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NVMFieldUser.h"
#import "NVMConstants.h"
#import "NSString+Random.h"

@implementation NVMFieldUser

-(id) init
{
    self = [super init];
    
    // initialize defaults
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
    if (lastRead == nil)     // App first run: set up user defaults.
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        
        // starting default values.
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"NVMFieldUser.name"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"NVMFieldUser.phone"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"NVMFieldUser.agency"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"NVMFieldUser.unit"];
        
        NSString* macAddr = [self getUUID];
        [[NSUserDefaults standardUserDefaults] setValue:macAddr forKey:@"NVMFieldUser.macAddress"];
        
        // sync the defaults to disk
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    
    return self;
}

- (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString*)string;
}

-(NSString*) name
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"NVMFieldUser.name"];
}

-(void) setName:(NSString*)_name
{
    [[NSUserDefaults standardUserDefaults] setValue:_name forKey:@"NVMFieldUser.name"];
}


-(NSString*) phone
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"NVMFieldUser.phone"];
}

-(void) setPhone:(NSString*)_phone
{
    [[NSUserDefaults standardUserDefaults] setValue:_phone forKey:@"NVMFieldUser.phone"];
}


-(NSString*) agency
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"NVMFieldUser.agency"];
}

-(void) setAgency:(NSString*)_agency
{
    [[NSUserDefaults standardUserDefaults] setValue:_agency forKey:@"NVMFieldUser.agency"];
}


-(NSString*) unit
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"NVMFieldUser.unit"];
}

-(void) setUnit:(NSString*)_unit
{
    [[NSUserDefaults standardUserDefaults] setValue:_unit forKey:@"NVMFieldUser.unit"];
}

-(NSString*) macAddress
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"NVMFieldUser.macAddress"];
}

-(NSDictionary*) createVarsTo:(NSString*)toId
                      Message:(NSDictionary*)msg
                        Error:(NSError**)error
{
    NSMutableDictionary* vars = [NSMutableDictionary dictionary];
    [vars setObject:toId forKey:@"to"];
    [vars setObject:self.name forKey:@"name"];
    [vars setObject:self.phone forKey:@"phone_number"];
    [vars setObject:self.agency forKey:@"agency"];
    [vars setObject:self.unit forKey:@"unit"];
    [vars setObject:@"3" forKey:@"ui"];
    [vars setObject:self.macAddress forKey:@"mac_addr"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:msg
                                                       options:0
                                                         error:error];
    if(!jsonData)
    {
        NSLog(@"(NVMFieldUser.createVarsTo:Message:\n\tUNABLE TO SERIALIZE JSON: %@",
              (*error).description);
        [vars setObject:@"" forKey:@"message"];
    }
    else{
        NSString* jsonString = [[NSString alloc]
                                initWithData:jsonData
                                    encoding:NSUTF8StringEncoding];
        [vars setObject:jsonString forKey:@"message"];
    }
    
    return vars;
}

-(NSURLRequest*) sendMessage:(NSDictionary*)vars
                 Attachments:(NSArray*)atch
                       Error:(NSError**)error
{
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:vars
                                                       options:0
                                                         error:error];
    if(!jsonData)
    {
        NSLog(@"(NVMFieldUser.createVarsTo:Message:\n\tUNABLE TO SERIALIZE JSON: %@", (*error).description);
        return nil;
    }
    else{
        NSString* jsonString = [[NSString alloc]
                                initWithData:jsonData
                                encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: kNVMSendMessageURL]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:54.0];
        [request setHTTPMethod:@"POST"];
        
        NSMutableData* body = [NSMutableData data];
        
        NSString* boundary = [NSString randomStringWithLength:64];
        [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
        
        [body appendData:boundaryData];
        [body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"vars\"\r\n\r\n%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for(int i = 0; i < atch.count; i++){
            UIImage* image = atch[i];
            NSData* imageData = UIImageJPEGRepresentation(image, 0.10);
            [body appendData:boundaryData];
            [body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file%d\"; filename=\"file%d.jpg\"\r\n\r\n", i+1, i+1] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData: imageData];
            [body appendData: [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];
        
        return request;
    }
}

@end

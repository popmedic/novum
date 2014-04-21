//
//  NVMFieldUser.m
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NVMFieldUser.h"
#import "UIDevice+macaddress.h"

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
        
        NSString* macAddr = [UIDevice macaddress];
        [[NSUserDefaults standardUserDefaults] setValue:macAddr forKey:@"NVMFieldUser.macAddress"];
        
        // sync the defaults to disk
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    
    return self;
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
{
    NSMutableDictionary* vars = [NSMutableDictionary dictionary];
    [vars setObject:toId forKey:@"to"];
    [vars setObject:self.name forKey:@"name"];
    [vars setObject:self.phone forKey:@"phone_number"];
    [vars setObject:self.agency forKey:@"agency"];
    [vars setObject:self.unit forKey:@"unit"];
    [vars setObject:@"3" forKey:@"ui"];
    [vars setObject:self.macAddress forKey:@"mac_addr"];
    [vars setObject:msg forKey:@"message"];
    
    return vars;
}

-(void) sendMessage:(NSDictionary*)vars Attachments:(NSArray*)atch
{
    
}

@end

//
//  NVMFieldUser.h
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVMFieldUser : NSObject

@property (getter = name,setter = setName:, nonatomic) NSString* name;
@property (getter = phone,setter = setPhone:, nonatomic) NSString* phone;
@property (getter = agency,setter = setAgency:, nonatomic) NSString* agency;
@property (getter = unit,setter = setUnit:, nonatomic)NSString* unit;
@property (readonly, getter = macAddress, nonatomic) NSString* macAddress;

@end

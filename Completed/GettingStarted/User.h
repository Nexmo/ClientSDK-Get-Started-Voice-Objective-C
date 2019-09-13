//
//  User.h
//  GettingStarted
//
//  Created by Paul Ardeleanu on 12/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <Foundation/Foundation.h>




#define kJaneName @"Jane"

#define kJaneUUID @"" //TODO: swap with a user uuid for Jane

#define kJaneJWT @"" //TODO: swap with a token for Jane



#define kJoeName @"Joe"

#define kJoeUUID @"" //TODO: swap with a userId for Joe

#define kJoeJWT @"" //TODO: swap with a token for Joe



#define kCalleePhoneNumber @"" //TODO: swap with a phone number to call





@interface User : NSObject
@property NSString *name;
@property NSString *uuid;
@property NSString *jwt;

-(instancetype)initWithName:(NSString *)name uuid:(NSString *)uuid jwt:(NSString *)jwt;

+(instancetype)Jane;
+(instancetype)Joe;
@end


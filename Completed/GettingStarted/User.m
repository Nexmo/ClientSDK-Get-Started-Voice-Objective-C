//
//  User.m
//  GettingStarted
//
//  Created by Paul Ardeleanu on 13/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithName:(NSString *)name uuid:(NSString *)uuid jwt:(NSString *)jwt {
    if(self = [super init]) {
        self.name = name;
        self.uuid = uuid;
        self.jwt = jwt;
    }
    return self;
}

+(instancetype)Jane {
    return [[User alloc] initWithName:kJaneName uuid:kJaneUUID jwt:kJaneJWT];
}

+(instancetype)Joe {
    return [[User alloc] initWithName:kJoeName uuid:kJoeUUID jwt:kJoeJWT];
}

@end

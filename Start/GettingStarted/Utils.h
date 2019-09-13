//
//  Utils.h
//  GettingStarted
//
//  Created by Paul Ardeleanu on 12/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NexmoClient/NexmoClient.h>
#import "User.h"


typedef NS_ENUM(NSInteger, CallStatus) {
    CallStatusUnknown,
    CallStatusInitiated,
    CallStatusInProgress,
    CallStatusError,
    CallStatusRejected,
    CallStatusCompleted
};


typedef NS_ENUM(NSInteger, InterfaceState) {
    InterfaceStateNotAuthenticated,
    InterfaceStateConnecting,
    InterfaceStateDisconnected,
    InterfaceStateLoggedIn,
    InterfaceStateCallInitiated,
    InterfaceStateCallRinging,
    InterfaceStateCallError,
    InterfaceStateInCall,
    InterfaceStateCallRejected,
    InterfaceStateCallEnded
};


InterfaceState computeInterfaceState (NXMClient * _Nonnull client, CallStatus callStatus,  NXMCall * _Nullable call);

NSString * _Nonnull callMemberStatusDescriptionFor(NXMCallMemberStatus status);

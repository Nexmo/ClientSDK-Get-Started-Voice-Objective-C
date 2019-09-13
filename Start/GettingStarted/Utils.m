//
//  Utils.m
//  GettingStarted
//
//  Created by Paul Ardeleanu on 13/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NexmoClient/NexmoClient.h>
#import "Utils.h"


InterfaceState computeInterfaceState (NXMClient * _Nonnull client, CallStatus callStatus,  NXMCall * _Nullable call)
{
    switch (client.connectionStatus) {
        case NXMConnectionStatusDisconnected:
            return InterfaceStateDisconnected;
            break;
        case NXMConnectionStatusConnecting:
            return InterfaceStateConnecting;
            break;
        case NXMConnectionStatusConnected:
            break;
    }
    if (call == nil) {
        switch (callStatus) {
        
            case CallStatusUnknown:
                return InterfaceStateLoggedIn;
                break;
            case CallStatusInitiated:
                return InterfaceStateCallInitiated;
                break;
            case CallStatusInProgress:
                return InterfaceStateLoggedIn;
                break;
            case CallStatusError:
                return InterfaceStateCallError;
                break;
            case CallStatusRejected:
                return InterfaceStateCallRejected;
                break;
            case CallStatusCompleted:
                return InterfaceStateCallEnded;
                break;
        }
    }
    
    NXMCallMember *otherMember = [call.otherCallMembers firstObject];
    switch (otherMember.status) {
        
            case NXMCallMemberStatusRinging:
            return InterfaceStateCallRinging;
            break;
            
            case NXMCallMemberStatusStarted:
            return InterfaceStateCallInitiated;
            break;
            
            case NXMCallMemberStatusFailed:
            case NXMCallMemberStatusTimeout:
            case NXMCallMemberStatusBusy:
            return InterfaceStateCallError;
            break;
            
            case NXMCallMemberStatusAnswered:
             return InterfaceStateInCall;
            break;
            
            case NXMCallMemberStatusRejected:
            return InterfaceStateCallRejected;
            break;
            
            case NXMCallMemberStatusCanceled:
            case NXMCallMemberStatusCompleted:
            return InterfaceStateCallEnded;

    }
}


NSString *callMemberStatusDescriptionFor(NXMCallMemberStatus status)
{
    switch (status) {
            case NXMCallMemberStatusRinging:
            return @"Ringing";
            break;
            case NXMCallMemberStatusStarted:
            return @"Started";
            break;
            case NXMCallMemberStatusAnswered:
            return @"Answered";
            break;
            case NXMCallMemberStatusCanceled:
            return @"Cancelled";
            break;
            case NXMCallMemberStatusFailed:
            return @"Failed";
            break;
            case NXMCallMemberStatusBusy:
            return @"Busy";
            break;
            case NXMCallMemberStatusTimeout:
            return @"Timeout";
            break;
            case NXMCallMemberStatusRejected:
            return @"Rejected";
            break;
            case NXMCallMemberStatusCompleted:
            return @"Completed";
    }
}

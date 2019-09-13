//
//  AppToAppCallViewController.m
//  GettingStarted
//
//  Created by Paul Ardeleanu on 12/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "AppToAppCallViewController.h"
#import <NexmoClient/NexmoClient.h>
#import "Utils.h"


@interface AppToAppCallViewController () <NXMClientDelegate, NXMCallDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@property NXMClient *client;
@property NXMCall *call;
@property CallStatus callStatus;

@end



@implementation AppToAppCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"App to App Call";
    [self.navigationItem setHidesBackButton:true];
    self.callStatus = CallStatusUnknown;
    [self.activityIndicator startAnimating];
    [self updateInterface];
    [self setupNexmoClient];
}

- (User *)callee {
    return [self.user.uuid isEqualToString:[User Jane].uuid] ? [User Joe] : [User Jane];
}


#pragma mark Setup

- (void)setupNexmoClient {
    self.client = [NXMClient shared];
    [self.client setDelegate:self];
    [self.client loginWithAuthToken:self.user.jwt];;
}


- (void)logout {
    [self.call hangup];
    [self.client logout];
    [self.navigationController popViewControllerAnimated:true];
}


- (IBAction)call:(id)sender {
    if (self.call != nil || self.callStatus == CallStatusInitiated) {
        [self endCall];
    } else {
        [self startCall];
    }
}

- (void)startCall {
    self.callStatus = CallStatusInitiated;
    __weak AppToAppCallViewController *weakSelf = self;
    [self.client call:[self callee].name callHandler:NXMCallHandlerInApp completionHandler:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if(error) {
            NSLog(@"✆  ‼️ call not created: %@", error);
            weakSelf.call = nil;
            [weakSelf updateInterface];
            return;
        }
        NSLog(@"✆  call: %@", call);
        weakSelf.call = call;
        [weakSelf.call setDelegate:self];
        [weakSelf updateInterface];
    }];
}

- (void)endCall {
    [self.call hangup];
    [self updateInterface];
}



//MARK:- NXMClientDelegate


- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    NSLog(@"✆  connectionStatusChanged - status: %ld - reason: %ld", (long)status, (long)reason);
    [self updateInterface];
}

- (void)client:(nonnull NXMClient *)client didReceiveError:(nonnull NSError *)error {
    NSLog(@"✆  ‼️ connection error: %@", [error localizedDescription]);
    [self updateInterface];
}

- (void)client:(nonnull NXMClient *)client didReceiveCall:(nonnull NXMCall *)call {
    NSLog(@"✆  📲 Incoming Call: %@", call);
    [self displayIncomingCallAlert:call];
}


#pragma mark IncomingCall

- (void)displayIncomingCallAlert:(NXMCall *)call {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayIncomingCallAlert:call];
        });
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incoming Call" message: [self callee].name preferredStyle:UIAlertControllerStyleAlert];
    
    __weak AppToAppCallViewController *weakSelf = self;
    UIAlertAction* answerAction = [UIAlertAction actionWithTitle:@"Answer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf didPressAnswerIncomingCall:call];
    }];
    
    UIAlertAction* rejectAction = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf didPressRejectIncomingCall:call];
    }];
    
    [alertController addAction:answerAction];
    [alertController addAction:rejectAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didPressAnswerIncomingCall:(NXMCall *)call {
    self.call = nil;
    self.callStatus = CallStatusInitiated;
    [self updateInterface];
    
    __weak AppToAppCallViewController *weakSelf = self;
    self.call = call;
    [call answer:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"✆  ‼️ error answering call: %@", error.localizedDescription);
            [weakSelf displayAlertWithTitle:@"Answer Call" andMessage:@"Error answering call"];
            weakSelf.call = nil;
            [weakSelf updateInterface];
            return;
        }
        [weakSelf.call setDelegate:self];
        NSLog(@"✆  🤙 call answered");
        [weakSelf updateInterface];
    }];
}

- (void)didPressRejectIncomingCall:(NXMCall *)call {
    self.call = nil;
    
    __weak AppToAppCallViewController *weakSelf = self;
    [call reject:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"✆  ‼️ error rejecting call: %@", error.localizedDescription);
            [weakSelf displayAlertWithTitle:@"Reject Call" andMessage:@"Error rejecting call"];
            return;
        }
        NSLog(@"✆  🤙 call rejected");
        [weakSelf updateInterface];
    }];
}

- (void)displayAlertWithTitle:(nonnull NSString *)title andMessage:(nonnull NSString *)message {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayAlertWithTitle:title andMessage:message];
        });
        return;
    }
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}



//MARK:- NXMCallDelegate

- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMCallMember *)callMember withStatus:(NXMCallMemberStatus)status {
    NSLog(@"✆  🤙 Call Status update | member: %@ | status: %@", callMember.user.displayName, callMemberStatusDescriptionFor(status));
    
    // call completed
    if (status == NXMCallMemberStatusCanceled || status == NXMCallMemberStatusCompleted) {
        self.callStatus = CallStatusCompleted;
        [self.call hangup];
        self.call = nil;
    }
    
    // call error
    if ( (call.myCallMember.memberId != callMember.memberId) && (status == NXMCallMemberStatusFailed || status == NXMCallMemberStatusBusy)) {
        self.callStatus = CallStatusError;
        [self.call hangup];
        self.call = nil;
    }
    
    // call rejected
    if ( (call.myCallMember.memberId != callMember.memberId) && (status == NXMCallMemberStatusRejected)) {
        self.callStatus = CallStatusRejected;
        [self.call hangup];
        self.call = nil;
    }
    
    [self updateInterface];
}

- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMCallMember *)callMember isMuted:(BOOL)muted {
    [self updateInterface];
}

- (void)call:(nonnull NXMCall *)call didReceive:(nonnull NSError *)error {
    NSLog(@"✆  ‼️ call error: %@", [error localizedDescription]);
    [self updateInterface];
}




#pragma mark - Interface

- (void)updateInterface {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateInterface];
        });
        return;
    }
    
    [self.activityIndicator stopAnimating];
    self.statusLabel.text = @"Ready.";
    self.callButton.alpha = 0;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
    
    InterfaceState interfaceState = computeInterfaceState(self.client, self.callStatus, self.call);
    switch (interfaceState) {
           
            case InterfaceStateNotAuthenticated:
            self.call = nil;
            self.statusLabel.text = @"Not Authenticated.";
            break;
            
            case InterfaceStateConnecting:
            [self.activityIndicator startAnimating];
            self.statusLabel.text = @"Connecting...";
            break;
            
            case InterfaceStateDisconnected:
            self.statusLabel.text = @"Disconnected";
            break;
            
            case InterfaceStateLoggedIn:
            self.statusLabel.text = [NSString stringWithFormat: @"Connected as %@", self.user.name];
            self.callButton.alpha = 1;
            [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", [self callee].name] forState:UIControlStateNormal];
            break;
            
            case InterfaceStateCallInitiated:
            self.navigationItem.leftBarButtonItem = nil;
            self.statusLabel.text = @"Connecting you to \(self.user.callee.rawValue)...";
            self.callButton.alpha = 1;
            [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
            break;
            
            case InterfaceStateCallRinging:
            self.navigationItem.leftBarButtonItem = nil;
            self.statusLabel.text = @"Ringing";
            self.callButton.alpha = 1;
            [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
            break;
            
            case InterfaceStateCallError:
            self.statusLabel.text = [NSString stringWithFormat:@"Could not call %@", [self callee].name];
            self.callButton.alpha = 1;
            [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", [self callee].name] forState:UIControlStateNormal];
            break;
            
            case InterfaceStateInCall:
            self.navigationItem.leftBarButtonItem = nil;
            self.statusLabel.text = [NSString stringWithFormat:@"Speaking with %@", [self callee].name];
            self.callButton.alpha = 1;
            [self.callButton setTitle:@"End call" forState:UIControlStateNormal];
            break;
            
            case InterfaceStateCallRejected:
            self.statusLabel.text = [NSString stringWithFormat:@"Call rejected by %@", [self callee].name];
            self.callButton.alpha = 1;
            [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", [self callee].name] forState:UIControlStateNormal];
            break;
            
            case InterfaceStateCallEnded:
            self.statusLabel.text = [NSString stringWithFormat:@"Call with %@ ended", [self callee].name];
            self.callButton.alpha = 1;
            [self.callButton setTitle:[NSString stringWithFormat:@"Call %@", [self callee].name] forState:UIControlStateNormal];
            break;
    }
    
}

@end

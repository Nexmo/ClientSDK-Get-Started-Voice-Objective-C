//
//  ReceivePhoneCallViewController.m
//  GettingStarted
//
//  Created by Paul Ardeleanu on 12/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "ReceivePhoneCallViewController.h"
#import <NexmoClient/NexmoClient.h>
#import "Utils.h"


@interface ReceivePhoneCallViewController () <NXMClientDelegate, NXMCallDelegate>

@property User *user;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *endCallButton;

@property NXMClient *client;
@property NXMCall *call;
@property CallStatus callStatus;

@end



@implementation ReceivePhoneCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    self.user = [User Jane];
    self.title = @"Receive a phone Call";
    [self.navigationItem setHidesBackButton:true];
    self.callStatus = CallStatusUnknown;
    [self.activityIndicator startAnimating];
    [self updateInterface];
    [self setupNexmoClient];
}


//MARK:  Setup Nexmo Client

- (void)setupNexmoClient {
    
}


- (void)logout {
    [self.call hangup];
    [self.client logout];
    [self.navigationController popViewControllerAnimated:true];
}


- (IBAction)endCall:(id)sender {
    
}



//MARK:- NXMClientDelegate


- (void)client:(nonnull NXMClient *)client didChangeConnectionStatus:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    
}

- (void)client:(nonnull NXMClient *)client didReceiveError:(nonnull NSError *)error {
    
}

- (void)client:(nonnull NXMClient *)client didReceiveCall:(nonnull NXMCall *)call {
    
}

//MARK: Incoming call - Accept


//MARK: Incoming call - Reject



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
    
}

- (void)call:(nonnull NXMCall *)call didUpdate:(nonnull NXMCallMember *)callMember isMuted:(BOOL)muted {
    
}

- (void)call:(nonnull NXMCall *)call didReceive:(nonnull NSError *)error {
    
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
    self.endCallButton.alpha = 0;
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
            break;
            
            case InterfaceStateCallInitiated:
            self.navigationItem.leftBarButtonItem = nil;
            self.statusLabel.text = [NSString stringWithFormat: @"Connecting you to %@", kCalleePhoneNumber];
            self.endCallButton.alpha = 1;
            break;
            
            case InterfaceStateCallRinging:
            self.navigationItem.leftBarButtonItem = nil;
            self.statusLabel.text = @"Ringing";
            self.endCallButton.alpha = 1;
            break;
            
            case InterfaceStateCallError:
            self.statusLabel.text = [NSString stringWithFormat:@"Could not call %@", kCalleePhoneNumber];
             break;
            
            case InterfaceStateInCall:
            self.navigationItem.leftBarButtonItem = nil;
            self.statusLabel.text = [NSString stringWithFormat:@"Speaking with %@", kCalleePhoneNumber];
            self.endCallButton.alpha = 1;
            break;
            
            case InterfaceStateCallRejected:
            self.statusLabel.text = [NSString stringWithFormat:@"Call rejected by %@", kCalleePhoneNumber];
            break;
            
            case InterfaceStateCallEnded:
            self.statusLabel.text = [NSString stringWithFormat:@"Call with %@ ended", kCalleePhoneNumber];
            break;
    }
    
}

@end

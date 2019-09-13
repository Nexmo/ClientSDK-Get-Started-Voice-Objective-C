//
//  UserSelectionViewController.m
//  GettingStarted
//
//  Created by Paul Ardeleanu on 12/09/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

#import "UserSelectionViewController.h"
#import "AppToAppCallViewController.h"
#import "Utils.h"

@interface UserSelectionViewController ()

@end

@implementation UserSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"App to App Call";
}

- (IBAction)loginAsJane:(id)sender {
    [self performSegueWithIdentifier:@"selectUser" sender:[User Jane]];
}

- (IBAction)loginAsJoe:(id)sender {
    [self performSegueWithIdentifier:@"selectUser" sender:[User Joe]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:AppToAppCallViewController.class] && [sender isKindOfClass:User.class]) {
        ((AppToAppCallViewController *) segue.destinationViewController).user = (User *)sender;
    }
}


@end

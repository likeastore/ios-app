//
//  LSDribbbleModalViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 20.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSDribbbleModalViewController.h"
#import "LSLikeastoreHTTPClient.h"

#import <ALPValidator/ALPValidator.h>

@interface LSDribbbleModalViewController ()

@end

@implementation LSDribbbleModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)connectDribbble:(id)sender {
    NSString *username = [self.dribbbleUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    ALPValidator *usernameValidator = [ALPValidator validatorWithType:ALPValidatorTypeString];
    [usernameValidator addValidationToEnsurePresenceWithInvalidMessage:@"Make sure you enter an username!"];
    [usernameValidator validate:username];
    
    if (!usernameValidator.isValid) {
        [self showErrorAlert:usernameValidator.errorMessages[0]];
        return;
    }
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api connectDribbble:username success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)close:(id)sender {
    __weak LSDribbbleModalViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.settingsController callNetworkConnectDissmissal];
    }];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end

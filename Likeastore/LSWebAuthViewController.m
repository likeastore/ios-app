//
//  LSWebAuthViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSWebAuthViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSSetupViewController.h"
#import "LSUser.h"

#import <NSURL+ParseQuery/NSURL+QueryParser.h>

@interface LSWebAuthViewController ()

@property (strong, nonatomic) NSString *firstTimeUserId;

@end

@implementation LSWebAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView setDelegate:self];
    
    NSURL *authUrl = [NSURL URLWithString:[AUTH_URL stringByAppendingFormat:@"/%@", self.authServiceName]];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:authUrl];
    
    [self.webView loadRequest:urlReq];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *responseURL = [request.URL absoluteString];
    
    if ([responseURL hasPrefix:[BLANK_HTML stringByAppendingString:@"?id="]]) {
        NSString *userId = [[[NSURL URLWithString:responseURL] parseQuery] objectForKey:@"id"];
        
        LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
        [api getEmailAndAPIToken:userId success:^(AFHTTPRequestOperation *operation, id userData) {
            @autoreleasepool {
                LSUser *user = [[LSUser alloc] initWithDictionary:userData];
                
                // show setup
                if (user.isFirstTimeUser) {
                    [self setFirstTimeUserId:user._id];
                    [self performSegueWithIdentifier:@"fromAuthToSetup" sender:self];
                    
                    // or continue auth
                } else {
                    NSDictionary *credentials = @{@"email":user.email, @"apiToken":user.apiToken};
                    
                    [api getAccessToken:credentials success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         [self performSegueWithIdentifier:@"fromAuthToFeed" sender:self];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self showErrorAlert];
                     }];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showErrorAlert];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - alert errors

- (void)showErrorAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong. Please check your connection or try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelAuth:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromAuthToSetup"]) {
        [(LSSetupViewController *)[segue destinationViewController] setUserId:self.firstTimeUserId];
    }
}

@end

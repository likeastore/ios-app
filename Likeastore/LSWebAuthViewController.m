//
//  LSWebAuthViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSWebAuthViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import <NSURL+ParseQuery/NSURL+QueryParser.h>

@interface LSWebAuthViewController ()

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
    NSLog(@"BOOL web view %@", request);
    
    if ([responseURL hasPrefix:[BLANK_HTML stringByAppendingString:@"?id="]]) {
        NSString *userId = [[[NSURL URLWithString:responseURL] parseQuery] objectForKey:@"id"];
        
        LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
        
        [api getEmailAndAPIToken:userId success:^(AFHTTPRequestOperation *operation, id user) {
            NSLog(@"success: %@", user);
            
            if ([user objectForKey:@"firstTimeUser"]) {
                NSLog(@"Show first time setup view");
            }
            
            NSDictionary *credentials = @{@"email": [user objectForKey:@"email"], @"apiToken": [user objectForKey:@"apiToken"]};
            
            [api getAccessToken:credentials success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                [self performSegueWithIdentifier:@"fromAuthToFeed" sender:self];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"login with credentials ERROR %@", error);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", error);
        }];
        
        return NO;
    }
    return YES;
}

- (IBAction)cancelAuth:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

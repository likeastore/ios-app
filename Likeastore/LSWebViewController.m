//
//  LSWebViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 04.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSWebViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@interface LSWebViewController ()

@end

@implementation LSWebViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self.webView setDelegate:self];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // setup tab bar icons
    CGFloat icon_size = 26.0f;
    UIColor *iconColor = [UIColor colorWithHexString:@"#00A3B5"];
    
    FAKIonIcons *backIcon = [FAKIonIcons ios7ArrowLeftIconWithSize:icon_size];
    [backIcon addAttribute:NSForegroundColorAttributeName value:iconColor];
    [self.backBarItem setTitle:nil];
    [self.backBarItem setImage:[backIcon imageWithSize:CGSizeMake(icon_size, icon_size)]];
    [self.backBarItem setImageInsets:UIEdgeInsetsMake(1.5, 0, -1.5, 0)];
    
    FAKIonIcons *forwardIcon = [FAKIonIcons ios7ArrowRightIconWithSize:icon_size];
    [forwardIcon addAttribute:NSForegroundColorAttributeName value:iconColor];
    [self.forwardBarItem setTitle:nil];
    [self.forwardBarItem setImage:[forwardIcon imageWithSize:CGSizeMake(icon_size, icon_size)]];
    [self.forwardBarItem setImageInsets:UIEdgeInsetsMake(1.5, 0, -1.5, 0)];
    
    FAKIonIcons *reloadIcon = [FAKIonIcons ios7RefreshEmptyIconWithSize:30.0f];
    [reloadIcon addAttribute:NSForegroundColorAttributeName value:iconColor];
    [self.reloadBarItem setTitle:nil];
    [self.reloadBarItem setImage:[reloadIcon imageWithSize:CGSizeMake(30.0f, 30.0f)]];
    [self.reloadBarItem setImageInsets:UIEdgeInsetsMake(2.0, 0, -2.0, 0)];
    
    FAKIonIcons *activityIcon = [FAKIonIcons ios7UploadOutlineIconWithSize:icon_size];
    [activityIcon addAttribute:NSForegroundColorAttributeName value:iconColor];
    [self.activityBarItem setTitle:nil];
    [self.activityBarItem setImage:[activityIcon imageWithSize:CGSizeMake(icon_size, icon_size)]];
    [self.activityBarItem setImageInsets:UIEdgeInsetsMake(1.0, 0, -1.0, 0)];
    
    [self.bar setTitle:self.urlTitle];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.urlToLoad];
    [self.webView loadRequest:urlRequest];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
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

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UIWebView delegates

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)authWebView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end

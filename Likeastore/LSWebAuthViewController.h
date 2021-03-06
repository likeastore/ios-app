//
//  LSWebAuthViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSettingsTableViewController.h"

@interface LSWebAuthViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *authServiceName;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) LSSettingsTableViewController *settingsController;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)cancelAuth:(id)sender;

@end

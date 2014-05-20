//
//  LSWebAuthViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSWebAuthViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *authServiceName;
@property (strong, nonatomic) NSString *urlString;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)cancelAuth:(id)sender;

@end

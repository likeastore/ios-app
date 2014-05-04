//
//  LSWebViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 04.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UINavigationItem *bar;
@property (strong, nonatomic) IBOutlet UITabBarItem *backBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *forwardBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *reloadBarItem;
@property (strong, nonatomic) IBOutlet UITabBarItem *activityBarItem;
- (IBAction)close:(id)sender;

@property (strong, nonatomic) NSString *urlTitle;
@property (strong, nonatomic) NSURL *urlToLoad;

@end

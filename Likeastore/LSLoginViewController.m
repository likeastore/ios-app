//
//  LSLoginViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSLoginViewController.h"
#import "LSWebAuthViewController.h"

#import <MFStoryboardPushSegue/MFStoryboardPopSegue.h>

@interface LSLoginViewController ()

@end

@implementation LSLoginViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)connectWithFacebook:(id)sender {
    LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
    [webAuthCtrl setAuthServiceName:@"facebook"];
    [self presentViewController:webAuthCtrl animated:YES completion:nil];
}

- (IBAction)connectWithGithub:(id)sender {
    LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
    [webAuthCtrl setAuthServiceName:@"github"];
    [self presentViewController:webAuthCtrl animated:YES completion:nil];
}

- (IBAction)connectWithTwitter:(id)sender {
    LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
    [webAuthCtrl setAuthServiceName:@"twitter"];
    [self presentViewController:webAuthCtrl animated:YES completion:nil];
}

#pragma mark - segues

- (IBAction)backFromEmailLoginUnwindSegueCallback:(UIStoryboardSegue *)segue {
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    return [[MFStoryboardPopSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
}

#pragma mark - gestures

- (IBAction)swipeGestureHandle:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded &&
        recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self performSegueWithIdentifier:@"showEmailLogin" sender:self];
    }
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

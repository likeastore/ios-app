//
//  LSLoginViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLoginViewController : UIViewController

- (IBAction)connectWithFacebook:(id)sender;
- (IBAction)connectWithGithub:(id)sender;
- (IBAction)connectWithTwitter:(id)sender;

- (IBAction)backFromEmailLoginUnwindSegueCallback:(UIStoryboardSegue *)segue;
- (IBAction)swipeGestureHandle:(UISwipeGestureRecognizer *)sender;

@end

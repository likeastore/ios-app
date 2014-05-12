//
//  LSEmailLoginViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 08.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSEmailLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)login:(id)sender;
- (IBAction)swipeGestureHandle:(UISwipeGestureRecognizer *)sender;

@end

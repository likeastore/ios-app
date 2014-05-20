//
//  LSDribbbleModalViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 20.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSDribbbleModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextField *dribbbleUsername;

- (IBAction)connectDribbble:(id)sender;
- (IBAction)close:(id)sender;

@end

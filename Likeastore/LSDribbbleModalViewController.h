//
//  LSDribbbleModalViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 20.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSettingsTableViewController.h"

@interface LSDribbbleModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextField *dribbbleUsername;
@property (strong, nonatomic) LSSettingsTableViewController *settingsController;

- (IBAction)connectDribbble:(id)sender;
- (IBAction)close:(id)sender;

@end

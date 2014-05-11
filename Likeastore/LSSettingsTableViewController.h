//
//  LSSettingsTableViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 11.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSSettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *signOutCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *clearCacheCell;

@end

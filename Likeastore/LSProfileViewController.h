//
//  LSProfileViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 11.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSharedUser.h"

@interface LSProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LSSharedUserDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *curatingCountLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)switchList:(id)sender;
- (IBAction)backFromCollectionDetailsUnwindSegueCallback:(UIStoryboardSegue *)segue;

@end

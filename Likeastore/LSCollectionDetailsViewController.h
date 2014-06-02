//
//  LSCollectionDetailsViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 16.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "LSCollection.h"
#import "LSSharedUser.h"
#import "LSFlagModalViewController.h"

@interface LSCollectionDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, UIActionSheetDelegate, LSSharedUserDelegate, LSFlagModalViewControllerDelegate>

@property (strong, nonatomic) LSCollection *collection;

@property (weak, nonatomic) IBOutlet UIButton *toggleFollowButton;
@property (weak, nonatomic) IBOutlet UILabel *collectionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;

- (IBAction)toggleFollowCollection:(id)sender;
- (IBAction)longPressGestureHandle:(UILongPressGestureRecognizer *)recognizer;

@end

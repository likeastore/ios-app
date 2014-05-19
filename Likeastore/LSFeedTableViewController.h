//
//  LSFeedTableViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "LSSharedUser.h"

@interface LSFeedTableViewController : UITableViewController <TTTAttributedLabelDelegate, LSSharedUserDelegate>

- (IBAction)longPressGestureHandle:(UILongPressGestureRecognizer *)sender;

@end

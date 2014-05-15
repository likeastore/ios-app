//
//  LSAllFavoritesViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <ILRemoteSearchBar/ILRemoteSearchBar.h>

@interface LSAllFavoritesViewController : UITableViewController <TTTAttributedLabelDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate, ILRemoteSearchBarDelegate>

@property (strong, nonatomic) NSString *favoritesType;

- (IBAction)longPressGestureHandle:(UILongPressGestureRecognizer *)sender;

- (void) toggleSearchBar;

@end

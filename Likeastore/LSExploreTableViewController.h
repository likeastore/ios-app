//
//  LSExploreTableViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 13.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ILRemoteSearchBar/ILRemoteSearchBar.h>

@interface LSExploreTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, ILRemoteSearchBarDelegate>

- (void) toggleSearchBar;

@end

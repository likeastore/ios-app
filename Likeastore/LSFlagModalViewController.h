//
//  LSFlagModalViewController.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 02.06.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LSFlagModalViewControllerDelegate <NSObject>

@optional
- (void)didFlagItemWithID:(NSString *)itemId forIndexPath:(NSIndexPath *)indexPath;

@end

@interface LSFlagModalViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <LSFlagModalViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *itemID;
@property (strong, nonatomic) NSIndexPath *itemIndexPath;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)close:(id)sender;

@end

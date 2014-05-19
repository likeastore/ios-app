//
//  LSExploreTableViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 13.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSExploreTableViewController.h"
#import "LSDropdownViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSCollection.h"
#import "LSCollectionsTableViewCell.h"
#import "LSCollectionDetailsViewController.h"
#import "UIImage+Color.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface LSExploreTableViewController ()

@property (strong, nonatomic) NSMutableArray *collections;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

@implementation LSExploreTableViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _collections = [[NSMutableArray alloc] init];
        _searchResults = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSearchBar];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // show activity indicator on first load
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
    [headerView setBackgroundColor:[UIColor colorWithHexString:@"#F3F3F6"]];
    [headerView addSubview:loader];
    [loader setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 35.0f)];
    self.tableView.tableHeaderView = headerView;
    [loader startAnimating];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getPopularCollections:^(AFHTTPRequestOperation *operation, id collectionsList) {
        @autoreleasepool {
            if ([collectionsList count] > 0) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSDictionary *collectionData in collectionsList) {
                    LSCollection *collection = [[LSCollection alloc] initWithDictionary:collectionData];
                    [result addObject:collection];
                }
                
                [self.collections addObjectsFromArray:result];
                [self.tableView reloadData];
                [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                
                [result removeAllObjects];
                result = nil;
            }
        }
        
        [loader stopAnimating];
        [loader removeFromSuperview];
        self.tableView.tableHeaderView = nil;

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loader stopAnimating];
        [loader removeFromSuperview];
        self.tableView.tableHeaderView = nil;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    LSDropdownViewController *menu = (LSDropdownViewController *) [[self parentViewController] parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    
    [menu.inboxButton setHidden:YES];
    [menu.settingsButton setHidden:YES];
    [menu.searchButton setHidden:NO];
    
    [menu setMenubarTitle:@"Explore"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSearchBar {
    [self.searchDisplayController.searchBar setBackgroundColor:[UIColor colorWithHexString:@"#1F212F"]];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#1F212F"]]];
    
    // set search cancel button color and size
    UIBarButtonItem *cancelButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [cancelButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.0f]} forState:UIControlStateNormal];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.collections count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSCollection *collection;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        collection = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        collection = [self.collections objectAtIndex:indexPath.row];
    }
    
    LSCollectionsTableViewCell *cell;
    if (collection.isDescription) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"collectionCell" forIndexPath:indexPath];
        cell.collectionDescriptionLabel.text = collection.description;
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"collectionOnlyTitleCell" forIndexPath:indexPath];
    }
    
    [cell.collectionImageView setContentMode:UIViewContentModeScaleAspectFill];
    [cell.collectionImageView.layer setMasksToBounds:YES];
    [cell.collectionImageView.layer setCornerRadius:3.0f];
    
    if (collection.thumbnailIsGIF) {
        [cell.collectionImageView setImage:[UIImage imageWithColor:[UIColor colorWithHexString:collection.color]]];
    } else {
        [cell.collectionImageView setImageWithURL:[NSURL URLWithString:collection.thumbnail] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:collection.color]]];
    }
    
    cell.collectionTitleLabel.text = collection.title;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

#pragma mark - Search delegates

- (void)toggleSearchBar {
    if (self.searchDisplayController.isActive) {
        [self.searchDisplayController setActive:NO animated:YES];
    } else {
        self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cleanAndDisableSearch];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self cleanAndDisableSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self makeSearchWithText:searchBar.text];
}

- (void)remoteSearchBar:(ILRemoteSearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self makeSearchWithText:searchText];
}

- (void)makeSearchWithText:(NSString *)text {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api searchPopularCollectionsByText:text success:^(AFHTTPRequestOperation *operation, id collections) {
        [self.searchResults removeAllObjects];
        
        @autoreleasepool {
            NSArray *data = [collections objectForKey:@"data"];
            if ([data count] > 0) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSDictionary *collectionData in data) {
                    LSCollection *collection = [[LSCollection alloc] initWithDictionary:collectionData];
                    [result addObject:collection];
                }
                
                [self.searchResults addObjectsFromArray:result];
                [self.searchDisplayController.searchResultsTableView reloadData];
                
                [result removeAllObjects];
                result = nil;
            }
        }
    } failure:nil];
}

- (void)cleanAndDisableSearch {
    [self.searchResults removeAllObjects];
    self.tableView.tableHeaderView = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LSCollection *collection;
    
    if (self.searchDisplayController.isActive) {
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        collection = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        collection = [self.collections objectAtIndex:indexPath.row];
    }
    
    [(LSCollectionDetailsViewController *)segue.destinationViewController setCollection:collection];
}

- (IBAction)backFromCollectionDetailsUnwindSegueCallback:(UIStoryboardSegue *)segue {
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

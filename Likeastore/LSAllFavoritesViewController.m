//
//  LSAllFavoritesViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSAllFavoritesViewController.h"
#import "LSDropdownViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSItem.h"
#import "LSEmptyMessageView.h"
#import "LSFavoritesTableViewCell.h"
#import "UIImage+Color.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <TOWebViewController/TOWebViewController.h>
#import <AHKActionSheet/AHKActionSheet.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

@interface LSAllFavoritesViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@property CGFloat searchPage;
@property (strong, nonatomic) NSString *searchText;

@end

@implementation LSAllFavoritesViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _searchResults = [[NSMutableArray alloc] init];
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self clearImageCache];
    [self setupSearchBar];
    
    // show activity indicator on first load
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loader setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 35.0f)];
    [self.view addSubview:loader];
    [loader startAnimating];
    
    __block CGFloat page = 1;
    __weak LSAllFavoritesViewController *weakSelf = self;
    
    // initial load
    [self setupItemsFor:page actionType:@"initial" success:^(BOOL nextPage) {
        page += 1;
        [loader stopAnimating];
        [loader removeFromSuperview];
    }];
    
    // pull to refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [loader stopAnimating];
        [loader removeFromSuperview];
        [weakSelf setupItemsFor:1 actionType:@"pullToRefresh" success:^(BOOL nextPage) {
            [weakSelf.tableView.pullToRefreshView stopAnimating];
        }];
    }];
    
    // infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [loader stopAnimating];
        [loader removeFromSuperview];
        [weakSelf setupItemsFor:page actionType:@"infiniteScroll" success:^(BOOL nextPage) {
            page += 1;
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [self parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    
    [menu.settingsButton setHidden:YES];
    [menu.inboxButton setHidden:YES];
    [menu.searchButton setHidden:NO];
    
    if ([self.favoritesType isEqualToString:@"inbox"]) {
        [menu setMenubarTitle:@"Inbox"];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"inbox opened"];
    } else if ([self.favoritesType isEqualToString:@"all"]) {
        [menu setMenubarTitle:@"All Favorites"];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"dashboard opened"];
    }
    
}

- (void)setupItemsFor:(CGFloat)page actionType:(NSString *)type success:(void (^)(BOOL nextPage))callback {
    __weak LSAllFavoritesViewController *weakSelf = self;
    
    if (page == 5) {
        [self clearImageCache];
    }
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    [api getFavoritesWithType:self.favoritesType byPage:page success:^(AFHTTPRequestOperation *operation, id data) {
        @autoreleasepool {
            NSArray *items = [data objectForKey:@"data"];
            
            if ([items count] > 0) {
                if ([type isEqualToString:@"pullToRefresh"]) {
                    [weakSelf.items removeAllObjects];
                }
                
                // populate data
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSDictionary *itemData in items) {
                    LSItem *item = [[LSItem alloc] initWithDictionary:itemData];
                    [result addObject:item];
                }
                
                [weakSelf.items addObjectsFromArray:result];
                [weakSelf.tableView reloadData];
                
                [result removeAllObjects];
                result = nil;
            } else if ([items count] == 0 && [type isEqualToString:@"initial"]) {
                NSString *message = [self.favoritesType isEqualToString:@"inbox"] ? @"Your inbox is empty, be more active!" : @"No favorites collected yet";
                LSEmptyMessageView *emptyView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyMessageView" owner:self options:nil] firstObject];
                [emptyView.emptyMessageLabel setText:message];
                [weakSelf.tableView setScrollEnabled:NO];
                [weakSelf.tableView setNxEV_emptyView:emptyView];
            }
        }
        
        callback([[data objectForKey:@"nextPage"] boolValue]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self clearImageCache];
}

- (void)clearImageCache {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearMemory];
    [cache clearDisk];
    [cache setValue:nil forKey:@"memCache"];
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
        return [self.items count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSItem *item;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        item = [self.items objectAtIndex:indexPath.row];
    }
    
    NSString *reuseIdentifier;
    if (item.isThumbnail) {
        reuseIdentifier = item.isAvatar ? @"favoritesAvatarThumbCell" : @"favoritesNoAvatarThumbCell";
    } else {
        reuseIdentifier = item.isAvatar ? @"favoritesAvatarTextCell" : @"favoritesNoAvatarTextCell";
    }
    
    LSFavoritesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath withData:item];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSItem *item;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        item = [self.items objectAtIndex:indexPath.row];
    }
    
    NSString *reuseIdentifier;
    if (item.isThumbnail) {
        reuseIdentifier = item.isAvatar ? @"favoritesAvatarThumbCell" : @"favoritesNoAvatarThumbCell";
    } else {
        reuseIdentifier = item.isAvatar ? @"favoritesAvatarTextCell" : @"favoritesNoAvatarTextCell";
    }
    
    LSFavoritesTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    [cell.itemDescription setMinimumLineHeight:18.0f];
    [cell.itemDescription setText:item.description];
    
    // calculate cell height based on dynamic fields
    CGFloat dynamicDescriptionHeight = [cell.itemDescription systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGFloat maxStaticHeight = 234.0f;
    if (!item.isAuthor) {
        maxStaticHeight -= 12.0f;
    }
    if (!item.isTitle) {
        maxStaticHeight -= 20.0f;
    }
    if (!item.isThumbnail) {
        maxStaticHeight -= 120.0f;
    }
    
    return dynamicDescriptionHeight + maxStaticHeight;
}

- (void)configureCell:(LSFavoritesTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withData:(LSItem *)item {
    
    if (item.isThumbnail) {
        [cell.itemThumbView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.itemThumbView.layer setMasksToBounds:YES];
        [cell.itemThumbView.layer setCornerRadius:3.0f];
        [cell.itemThumbView setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[UIImage imageNamed:@"default-preview.png"]];
        
        if (item.thumbnailIsGIF) {
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
    }
    
    if (item.isAvatar) {
        // make circle avatars
        [cell.itemAvatarView.layer setMasksToBounds:YES];
        [cell.itemAvatarView.layer setCornerRadius:cell.itemAvatarView.frame.size.height/2];
        [cell.itemAvatarView setImageWithURL:[NSURL URLWithString:item.avatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
    }
    
    // author, title and description
    [cell.itemAuthor setText:item.author];
    [cell.itemTitle setText:item.title];
    [cell.itemDescription setDelegate:self];
    [cell.itemDescription setMinimumLineHeight:18.0f];
    [cell detectLinksInLabel:cell.itemDescription withColor:[UIColor colorWithHexString:@"#f03e56"]];
    [cell.itemDescription setText:item.description];
    
    // network type
    NSString *imageName = [item.type stringByAppendingFormat:@".png"];
    UIImage *typeImage = [UIImage imageNamed:imageName];
    [cell.itemTypeView setImage:typeImage];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self openWebView:url];
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath withID:(NSString *)_id {
    // remove from table
    if (self.searchDisplayController.isActive) {
        [self.searchResults removeObjectAtIndex:indexPath.row];
        [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        [self.items removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    // send api call
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api deleteFavoritesItemByID:_id success:nil failure:nil];
}

- (void)openWebView:(NSURL *)url {
    TOWebViewController *webViewCtrl = [[TOWebViewController alloc] initWithURL:url];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webViewCtrl];
    [nav.view setTintColor:[UIColor colorWithHexString:@"#3eb6b9"]];
    
    [self presentViewController:nav animated:YES completion:nil];
}

# pragma mark - Gestures

- (IBAction)longPressGestureHandle:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSIndexPath *indexPath;
        if (self.searchDisplayController.isActive) {
            CGPoint point = [recognizer locationInView:self.searchDisplayController.searchResultsTableView];
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForRowAtPoint:point];
        } else {
            CGPoint point = [recognizer locationInView:self.tableView];
            indexPath = [self.tableView indexPathForRowAtPoint:point];
        }
        
        if (indexPath) {
            [self showActionSheetForIndexPath:indexPath];
        }
    }
}

- (void) showActionSheetForIndexPath:(NSIndexPath *)indexPath {
    LSItem *item;
    if (self.searchDisplayController.isActive) {
        item = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        item = [self.items objectAtIndex:indexPath.row];
    }
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:item.source];
    
    // custom styles
    [actionSheet setBlurTintColor:[UIColor colorWithHexString:@"#1f212f" alpha:0.9f]];
    [actionSheet setBlurRadius:3.0f];
    [actionSheet setButtonHeight:50.0f];
    [actionSheet setCancelButtonHeight:50.0f];
    [actionSheet setCancelButtonShadowColor:[UIColor colorWithHexString:@"#303140" alpha:0.98f]];
    [actionSheet setSeparatorColor:[UIColor colorWithHexString:@"#a3a5c0" alpha:0.6f]];
    [actionSheet setSelectedBackgroundColor:[UIColor colorWithHexString:@"#161625" alpha:0.6f]];
    
    // fonts and colors
    UIColor *mainColor = [UIColor colorWithHexString:@"#e9e9e9"];
    UIColor *pinkColor = [UIColor colorWithHexString:@"#f03e56"];
    UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    CGFloat icon_size = 24.0f;
    
    actionSheet.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:14.0f], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#43c2c2"]};
    
    actionSheet.buttonTextAttributes = @{NSFontAttributeName:defaultFont,
                                         NSForegroundColorAttributeName:mainColor};
    actionSheet.cancelButtonTextAttributes = @{NSFontAttributeName:defaultFont,
                                               NSForegroundColorAttributeName:mainColor};
    actionSheet.destructiveButtonTextAttributes = @{NSFontAttributeName:defaultFont,
                                                    NSForegroundColorAttributeName:pinkColor};
    
    // create menu items and handlers
    __weak LSAllFavoritesViewController *weakSelf = self;
    
    FAKIonIcons *sourceIcon = [FAKIonIcons ios7UploadOutlineIconWithSize:icon_size];
    [sourceIcon addAttribute:NSForegroundColorAttributeName value:mainColor];
    
    [actionSheet addButtonWithTitle:@"Go to source"
                              image:[sourceIcon imageWithSize:CGSizeMake(icon_size, icon_size)]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                [mixpanel track:@"source link opened"];
                                
                                [weakSelf openWebView:[NSURL URLWithString:item.source]];
                            }];
    
    FAKIonIcons *deleteIcon = [FAKIonIcons ios7TrashOutlineIconWithSize:icon_size];
    [deleteIcon addAttribute:NSForegroundColorAttributeName value:pinkColor];
    
    [actionSheet addButtonWithTitle:@"Delete"
                              image:[deleteIcon imageWithSize:CGSizeMake(icon_size, icon_size)]
                               type:AHKActionSheetButtonTypeDestructive
                            handler:^(AHKActionSheet *as) {
                                [weakSelf deleteItemAtIndexPath:indexPath withID:item._id];
                            }];
    
    [actionSheet show];
}

#pragma mark - Search methods and delegates

- (void)toggleSearchBar {
    if (self.searchDisplayController.isActive) {
        [self.searchDisplayController setActive:NO animated:YES];
    } else {
        self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    }
}

- (void)setupSearchBar {
    self.tableView.tableHeaderView = nil;
    
    UIColor *searchBackground = [UIColor colorWithHexString:@"#1F212F"];
    [self.searchDisplayController.searchBar setBackgroundColor:searchBackground];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:searchBackground]];
    [(ILRemoteSearchBar *)self.searchDisplayController.searchBar setTimeToWait:1.0];
    
    // set search cancel button color and size
    UIBarButtonItem *cancelButton = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [cancelButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.0f]} forState:UIControlStateNormal];
    
    [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithHexString:@"#f3f3f6"]];
    
    // register custom cell nibs
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FavoritesAvatarTextCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesAvatarTextCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FavoritesNoAvatarTextCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesNoAvatarTextCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FavoritesAvatarThumbCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesAvatarThumbCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FavoritesNoAvatarThumbCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesNoAvatarThumbCell"];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cleanAndDisableSearch];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self cleanAndDisableSearch];
}

- (void)cleanAndDisableSearch {
    [self.searchResults removeAllObjects];
    self.tableView.tableHeaderView = nil;
}

- (void)remoteSearchBar:(ILRemoteSearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self startSearchText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self startSearchText:searchBar.text];
}

- (void)startSearchText:(NSString *)text {
    self.searchPage = 1;
    self.searchText = text;
    
    __weak LSAllFavoritesViewController *weakSelf = self;
    
    // initial search request
    [self makeSearchWithText:self.searchText byPage:self.searchPage success:^(BOOL nextPage){
        if (nextPage) weakSelf.searchPage += 1;
    }];
    
    // infinite scrolling
    [self.searchDisplayController.searchResultsTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf makeSearchWithText:weakSelf.searchText byPage:weakSelf.searchPage success:^(BOOL nextPage) {
             if (nextPage) weakSelf.searchPage += 1;
             [weakSelf.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
        }];
     }];
}

- (void)makeSearchWithText:(NSString *)text byPage:(CGFloat)page success:(void (^)(BOOL nextPage))callback {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"search opened"];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api searchFavoritesByText:text byPage:page success:^(AFHTTPRequestOperation *operation, id favorites) {
        @autoreleasepool {
            if (page == 1) {
                [self.searchResults removeAllObjects];
            }
            
            if (page == 5) {
                [self clearImageCache];
            }
            
            NSArray *items = [favorites objectForKey:@"data"];
            if ([items count] > 0) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSDictionary *itemData in items) {
                    LSItem *item = [[LSItem alloc] initWithDictionary:itemData];
                    [result addObject:item];
                }
                
                [self.searchResults addObjectsFromArray:result];
                [self.searchDisplayController.searchResultsTableView reloadData];
                
                [result removeAllObjects];
                result = nil;
            }
        }
        callback([[favorites objectForKey:@"nextPage"] boolValue]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO);
    }];
}

@end

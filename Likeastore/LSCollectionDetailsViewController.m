//
//  LSCollectionDetailsViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 16.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSCollectionDetailsViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSSharedUser.h"
#import "LSAllFavoritesViewController.h"
#import "LSDropdownViewController.h"
#import "LSCollection.h"
#import "LSItem.h"
#import "LSFavoritesTableViewCell.h"
#import "LSEmptyMessageView.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <TOWebViewController/TOWebViewController.h>
#import <AHKActionSheet/AHKActionSheet.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

@interface LSCollectionDetailsViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation LSCollectionDetailsViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"collection opened"];
    
    [self clearImageCache];
    
    LSSharedUser *sharedUser = [LSSharedUser create];
    [sharedUser setDelegate:self];
    [sharedUser needsAuthorizedUser:NO];
    
    [self.collectionTitleLabel setText:self.collection.title];
    [self.followersCountLabel setText:[self.collection.followersCount stringValue]];
    
    [self setupTableView];
    
    // show activity indicator on first load
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loader setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 165.0f)];
    [self.view addSubview:loader];
    [loader startAnimating];
    
    __block CGFloat page = 1;
    __weak LSCollectionDetailsViewController *weakSelf = self;
    
    [self loadItemsFor:page actionType:@"initial" success:^(BOOL nextPage){
        page += 1;
        
        [loader stopAnimating];
        [loader removeFromSuperview];
    }];
    
    // infinite scrolling
    [self.itemsTableView addInfiniteScrollingWithActionHandler:^{
        [loader stopAnimating];
        [loader removeFromSuperview];
        [weakSelf loadItemsFor:page actionType:@"infiniteScroll" success:^(BOOL nextPage){
            page += 1;
            [weakSelf.itemsTableView.infiniteScrollingView stopAnimating];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [[self parentViewController] parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    
    [menu.inboxButton setHidden:YES];
    [menu.settingsButton setHidden:YES];
    [menu.searchButton setHidden:YES];
    
    [menu setMenubarTitle:@"Collection"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self clearImageCache];
}

- (void)loadItemsFor:(CGFloat)page actionType:(NSString *)type success:(void (^)(BOOL nextPage))callback {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    [api getFavoritesFromCollectionID:self.collection._id byPage:page success:^(AFHTTPRequestOperation *operation, id favorites) {
        @autoreleasepool {
            NSArray *items = [favorites objectForKey:@"data"];
            
            if ([items count] > 0) {
                // populate data
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSDictionary *itemData in items) {
                    LSItem *item = [[LSItem alloc] initWithDictionary:itemData];
                    [result addObject:item];
                }
                
                [self.items addObjectsFromArray:result];
                [self.itemsTableView reloadData];
                
                [result removeAllObjects];
            } else if ([items count] == 0 && [type isEqualToString:@"initial"]) {
                LSEmptyMessageView *emptyView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyMessageView" owner:self options:nil] firstObject];
                [emptyView.emptyMessageLabel setText:@"Collection is empty."];
                [self.itemsTableView setScrollEnabled:NO];
                [self.itemsTableView setNxEV_emptyView:emptyView];
            }
        }
        
        callback([[favorites objectForKey:@"nextPage"] boolValue]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO);
    }];
}

- (void)setupTableView {
    [self.itemsTableView setDelegate:self];
    [self.itemsTableView setDataSource:self];
    
    // register custom cell nibs
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"FavoritesAvatarTextCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesAvatarTextCell"];
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"FavoritesNoAvatarTextCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesNoAvatarTextCell"];
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"FavoritesAvatarThumbCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesAvatarThumbCell"];
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"FavoritesNoAvatarThumbCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"favoritesNoAvatarThumbCell"];
}

- (void)clearImageCache {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearMemory];
    [cache clearDisk];
    [cache setValue:nil forKey:@"memCache"];
}

- (void)haveSharedUser:(LSUser *)user {
    // check if user owns this collection
    if ([self.collection.ownerID isEqualToString:user._id]) {
        [self setupOwnerButtonStyles];
        
    // check if user is following this collection
    } else if ([self.collection followedByUser:user._id]) {
        [self setupFollowingButtonStyles];
    } else {
        [self setupFollowButtonStyles];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSItem *item = [self.items objectAtIndex:indexPath.row];
    
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
    LSItem *item = [self.items objectAtIndex:indexPath.row];
    
    NSString *reuseIdentifier;
    if (item.isThumbnail) {
        reuseIdentifier = item.isAvatar ? @"favoritesAvatarThumbCell" : @"favoritesNoAvatarThumbCell";
    } else {
        reuseIdentifier = item.isAvatar ? @"favoritesAvatarTextCell" : @"favoritesNoAvatarTextCell";
    }
    
    LSFavoritesTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [self.itemsTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
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

- (void)openWebView:(NSURL *)url {
    TOWebViewController *webViewCtrl = [[TOWebViewController alloc] initWithURL:url];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webViewCtrl];
    [nav.view setTintColor:[UIColor colorWithHexString:@"#3eb6b9"]];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Gestures

- (void) showActionSheetForIndexPath:(NSIndexPath *)indexPath {
    LSItem *item = [self.items objectAtIndex:indexPath.row];
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
    
    // create menu items
    FAKIonIcons *sourceIcon = [FAKIonIcons ios7UploadOutlineIconWithSize:icon_size];
    [sourceIcon addAttribute:NSForegroundColorAttributeName value:mainColor];
    [actionSheet addButtonWithTitle:@"Go to source"
                              image:[sourceIcon imageWithSize:CGSizeMake(icon_size, icon_size)]
                               type:AHKActionSheetButtonTypeDefault
                            handler:^(AHKActionSheet *as) {
                                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                [mixpanel track:@"source link opened"];
                                
                                [self openWebView:[NSURL URLWithString:item.source]];
                            }];
    
    [actionSheet show];
}

- (IBAction)longPressGestureHandle:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [recognizer locationInView:self.itemsTableView];
        NSIndexPath *indexPath = [self.itemsTableView indexPathForRowAtPoint:point];
        
        if (indexPath) {
            [self showActionSheetForIndexPath:indexPath];
        }
    }
}

#pragma mark - Follow and unfollow

- (IBAction)toggleFollowCollection:(id)sender {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    LSUser *user = [LSSharedUser sharedUser];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    if ([self.collection followedByUser:user._id]) {
        [self setupFollowButtonStyles];
        [mixpanel track:@"collection unfollowed"];
        [api unfollowCollectionByID:self.collection._id success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [self.collection removeFollower:user._id];
             user.followCollectionsCount -= 1;
         } failure:nil];
    } else {
        [self setupFollowingButtonStyles];
        [mixpanel track:@"collection followed"];
        [api followCollectionByID:self.collection._id success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [self.collection addFollower:user._id];
             user.followCollectionsCount += 1;
         } failure:nil];
    }
}

- (void)setupFollowingButtonStyles {
    UIColor *pinkColor = [UIColor colorWithHexString:@"#f2485f"];
    
    [self.toggleFollowButton setTitle:@"Following" forState:UIControlStateNormal];
    [self.toggleFollowButton setBackgroundColor:[UIColor clearColor]];
    [self.toggleFollowButton setTitleColor:pinkColor forState:UIControlStateNormal];
    [self.toggleFollowButton setTintColor:pinkColor];
    [self.toggleFollowButton.layer setBorderWidth:1.5f];
    [self.toggleFollowButton.layer setBorderColor:pinkColor.CGColor];
}

- (void)setupFollowButtonStyles {
    [self.toggleFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    [self.toggleFollowButton setBackgroundColor:[UIColor colorWithHexString:@"#f2485f"]];
    [self.toggleFollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.toggleFollowButton setTintColor:[UIColor whiteColor]];
    [self.toggleFollowButton.layer setBorderWidth:0.0f];
    [self.toggleFollowButton.layer setBorderColor:[UIColor clearColor].CGColor];
}

- (void)setupOwnerButtonStyles {
    UIColor *greenColor = [UIColor colorWithHexString:@"#3daeae"];
    
    [self.toggleFollowButton setEnabled:NO];
    [self.toggleFollowButton setTitle:@"Owner" forState:UIControlStateNormal];
    [self.toggleFollowButton setBackgroundColor:[UIColor clearColor]];
    [self.toggleFollowButton setTitleColor:greenColor forState:UIControlStateNormal];
    [self.toggleFollowButton setTintColor:greenColor];
    [self.toggleFollowButton.layer setBorderWidth:1.5f];
    [self.toggleFollowButton.layer setBorderColor:greenColor.CGColor];
}

@end

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
#import "UIImage+Color.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <TOWebViewController/TOWebViewController.h>
#import <AHKActionSheet/AHKActionSheet.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import <Underscore.m/Underscore.h>

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
    
    LSSharedUser *sharedUser = [LSSharedUser create];
    [sharedUser setDelegate:self];
    [sharedUser needsAuthorizedUser];
    
    [self.collectionTitleLabel setText:self.collection.title];
    [self.followersCountLabel setText:[self.collection.followersCount stringValue]];
    
    [self setupTableView];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getFavoritesFromCollectionID:self.collection._id byPage:1 success:^(AFHTTPRequestOperation *operation, id favorites) {
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
                result = nil;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@", error);
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
        UIColor *greenColor = [UIColor colorWithHexString:@"#3daeae"];
        
        [self.toggleFollowButton setEnabled:NO];
        [self.toggleFollowButton setTitle:@"Owner" forState:UIControlStateNormal];
        [self.toggleFollowButton setBackgroundColor:[UIColor clearColor]];
        [self.toggleFollowButton setTitleColor:greenColor forState:UIControlStateNormal];
        [self.toggleFollowButton setTintColor:greenColor];
        [self.toggleFollowButton.layer setBorderWidth:1.5f];
        [self.toggleFollowButton.layer setBorderColor:greenColor.CGColor];
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)toggleFollowCollection:(id)sender {
    if ([self.collection followedByUser:[LSSharedUser sharedUser]._id]) {
        [self setupFollowButtonStyles];
    } else {
        [self setupFollowingButtonStyles];
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

@end

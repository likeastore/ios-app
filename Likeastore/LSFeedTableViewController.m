//
//  LSFeedTableViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSFeedTableViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSItem.h"
#import "LSCollection.h"
#import "LSFeedTableViewCell.h"
#import "LSDropdownViewController.h"
#import "LSSharedUser.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <TOWebViewController/TOWebViewController.h>
#import <AHKActionSheet/AHKActionSheet.h>
#import <FontAwesomeKit/FAKIonIcons.h>

@interface LSFeedTableViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation LSFeedTableViewController

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
    
    [self clearImageCache];

    // show activity indicator on first load
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loader setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 35.0f)];
    [self.view addSubview:loader];
    [loader startAnimating];
    
    __block CGFloat page = 1;
    __weak LSFeedTableViewController *weakSelf = self;
    
    // initial load
    [self setupItemsFor:page actionType:@"initial" success:^{
        page += 1;
        [loader stopAnimating];
        [loader removeFromSuperview];
    }];
    
    // pull to refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [loader stopAnimating];
        [loader removeFromSuperview];
        [weakSelf setupItemsFor:1 actionType:@"pullToRefresh" success:^{
            [weakSelf.tableView.pullToRefreshView stopAnimating];
        }];
    }];
    
    // infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [loader stopAnimating];
        [loader removeFromSuperview];
        [weakSelf setupItemsFor:page actionType:@"infiniteScroll" success:^{
            page += 1;
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [self parentViewController];
    [menu.logoView setHidden:NO];
    [menu.titleLabel setHidden:YES];
    
    [menu.settingsButton setHidden:YES];
    [menu.searchButton setHidden:YES];
    [menu.inboxButton setHidden:NO];
    
    LSSharedUser *sharedUser = [LSSharedUser new];
    [sharedUser setDelegate:self];
    [sharedUser checkUserAuthorized];
}

- (void)setupItemsFor:(CGFloat)page actionType:(NSString *)type success:(void (^)())callback {
    __weak LSFeedTableViewController *weakSelf = self;
    
    [weakSelf clearImageCache];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    [api getFeed:page success:^(AFHTTPRequestOperation *operation, id data) {
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
            }
        }
        
        callback();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self clearImageCache];
    // Dispose of any resources that can be recreated.
}

- (void)clearImageCache {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearMemory];
    [cache clearDisk];
    [cache setValue:nil forKey:@"memCache"];
}

#pragma mark - auth delagates

- (void)didAuthorizationCheck:(BOOL)isAuthorized {
    if (!isAuthorized) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        // init user
        [LSSharedUser sharedUser];
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
    NSString *reuseIdentfier = item.isThumbnail ? @"thumbCell" : @"textCell";
    LSFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentfier forIndexPath:indexPath];
    
    if (item.isThumbnail) {
        cell.itemThumb.contentMode = UIViewContentModeScaleAspectFill;
        cell.itemThumb.layer.masksToBounds = YES;
        cell.itemThumb.layer.borderWidth = 1.0f;
        cell.itemThumb.layer.borderColor = [UIColor colorWithHexString:@"#eee"].CGColor;
        [cell.itemThumb setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[UIImage imageNamed:@"default-preview.png"]];
        
        if (item.thumbnailIsGIF) {
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
    }
    [self configureCell:cell forRowAtIndexPath:indexPath withData:item];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSItem *item = [self.items objectAtIndex:indexPath.row];
    
    NSString *reuseIdentifier = item.isThumbnail ? @"thumbCell" : @"textCell";
    LSFeedTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    [cell.itemDescription setMinimumLineHeight:18.0f];
    [cell.itemDescription setText:item.description];
    
    CGFloat dynamicDescriptionHeight = [cell.itemDescription systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    if (item.isThumbnail) {
        return dynamicDescriptionHeight + (item.isTitle ? 386.0f : 368.0f);
    } else {
        return dynamicDescriptionHeight + (item.isTitle ? 136.0f : 118.0f);
    }
}

- (void)configureCell:(LSFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withData:(LSItem *)item {
    
    // collection info
    LSCollection *itemCollection = [[LSCollection alloc] initWithDictionary:item.collection];
    [cell.collectionTitle setText:itemCollection.title];
    [cell.collectionOwner setText:[NSString stringWithFormat:@"by %@", itemCollection.ownerName]];
    [cell.collectionOwnerAvatarView setImageWithURL:[NSURL URLWithString:itemCollection.ownerAvatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
    
    // make circle avatars
    CALayer *layer = [cell.collectionOwnerAvatarView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:cell.collectionOwnerAvatarView.frame.size.height/2];
    
    // network type
    NSString *imageName = [item.type stringByAppendingFormat:@".png"];
    UIImage *typeImage = [UIImage imageNamed:imageName];
    [cell.typeIconView setImage:typeImage];
    
    // title
    [cell.itemTitle setText:item.title];
    
    // description
    [cell.itemDescription setDelegate:self];
    [cell.itemDescription setMinimumLineHeight:18.0f];
    [cell detectLinksInLabel:cell.itemDescription withColor:[UIColor colorWithHexString:@"#f03e56"]];
    [cell.itemDescription setText:item.description];
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

# pragma mark - Gestures

- (IBAction)longPressGestureHandle:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        
        if (indexPath) {
            [self showActionSheetForIndexPath:indexPath];
        }
    }
}

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
                                [self openWebView:[NSURL URLWithString:item.source]];
                            }];
    
    [actionSheet show];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

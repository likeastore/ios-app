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
#import "LSFavoritesTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <TOWebViewController/TOWebViewController.h>

@interface LSAllFavoritesViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation LSAllFavoritesViewController

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
    
    // initial load
    [self setupItemsFor:page actionType:@"initial" success:^{
        page += 1;
        [loader stopAnimating];
        [loader removeFromSuperview];
    }];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [self parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    [menu setMenubarTitle:@"All Favorites"];
}

- (void)setupItemsFor:(CGFloat)page actionType:(NSString *)type success:(void (^)())callback {
    __weak LSAllFavoritesViewController *weakSelf = self;
    
    [weakSelf clearImageCache];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    [api getAllFavorites:page success:^(AFHTTPRequestOperation *operation, id data) {
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
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearImageCache {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
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
    NSString *reuseIdentfier = @"favoritesTextCell";
    LSFavoritesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentfier forIndexPath:indexPath];
    
    [cell.itemAvatarView setImageWithURL:[NSURL URLWithString:item.avatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
    
    // make circle avatars
    CALayer *layer = [cell.itemAvatarView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:cell.itemAvatarView.frame.size.height/2];
    
    [cell.itemAuthor setText:item.author];
    [cell.itemTitle setText:item.title];
    [cell.itemDescription setText:item.description];
    
    // network type
    NSString *imageName = [item.type stringByAppendingFormat:@".png"];
    UIImage *typeImage = [UIImage imageNamed:imageName];
    [cell.itemTypeView setImage:typeImage];
    
    
    /*if (item.isThumbnail) {
        cell.itemThumb.contentMode = UIViewContentModeScaleAspectFill;
        cell.itemThumb.layer.borderWidth = 1.0f;
        cell.itemThumb.layer.borderColor = [UIColor colorWithHexString:@"#ddd"].CGColor;
        [cell.itemThumb setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[UIImage imageNamed:@"default-preview.png"]];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath withData:item];
    
    if (!item.isTitle) {
        cell.itemTitle.frame = CGRectMake(cell.itemTitle.frame.origin.x,cell.itemTitle.frame.origin.y, 280.0f, 0.0f);
    }*/
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300.0f;
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

@end

//
//  LSFeedTableViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 30.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSFeedTableViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "LSItem.h"
#import "LSCollection.h"
#import "LSSimpleTableViewCell.h"

@interface LSFeedTableViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (strong, nonatomic) LSSimpleTableViewCell *prototypeTextCell;

@end

@implementation LSFeedTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.offscreenCells = [NSMutableDictionary dictionary];
        // Custom initialization
    }
    return self;
}

- (LSSimpleTableViewCell *)prototypeTextCell {
    if (!_prototypeTextCell) {
        _prototypeTextCell = [self.tableView dequeueReusableCellWithIdentifier:@"textCell"];
    }
    return _prototypeTextCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getFeed:^(AFHTTPRequestOperation *operation, id data) {
        self.items = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"data"]];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    LSItem *itemFeed = [[LSItem alloc] initWithDictionary:[self.items objectAtIndex:indexPath.row]];
    NSString *reuseIdentfier = itemFeed.isThumbnail ? @"thumbCell" : @"textCell";
    LSSimpleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentfier forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath withData:itemFeed];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSItem *itemFeed = [[LSItem alloc] initWithDictionary:[self.items objectAtIndex:indexPath.row]];
    NSString *reuseIdentifier = itemFeed.isThumbnail ? @"thumbCell" : @"textCell";
    LSSimpleTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath withData:itemFeed];
    
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    NSLog(@"%@", [cell.itemDescription text]);
    NSLog(@"%f", [cell.itemDescription systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
    NSLog(@"%f", [cell.itemDescription sizeThatFits:CGSizeZero].height);
    
    if (itemFeed.isThumbnail) {
        return 500;
    }
    return [cell.itemDescription systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height+134;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//}

- (void)configureCell:(LSSimpleTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withData:(LSItem *)itemFeed {
    
    LSCollection *itemCollection = [[LSCollection alloc] initWithDictionary:itemFeed.collection];
    
    if (itemFeed.isThumbnail) {
        // Lazy load thumbnail image to view, set dynamic heights
        UIImageView __weak *itemThumbView = cell.itemThumb;
        CGFloat x = itemThumbView.frame.origin.x;
        CGFloat y = itemThumbView.frame.origin.y;
        
        [itemThumbView setImageWithURL:[NSURL URLWithString:itemFeed.thumbnail] placeholderImage:[UIImage imageNamed:@"default-preview.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            CGSize thumbSize = image.size;
            CGFloat thumbWidth = 310.0f;
            CGFloat thumbHeight = (thumbWidth/thumbSize.width)*thumbSize.height;
            itemThumbView.frame = CGRectMake(x, y, thumbWidth, thumbHeight);
        }];
    }
    
    // collection info
    [cell.collectionTitle setText:itemCollection.title];
    [cell.collectionOwner setText:[NSString stringWithFormat:@"by %@", itemCollection.ownerName]];
    [cell.collectionOwnerAvatarView setImageWithURL:[NSURL URLWithString:itemCollection.ownerAvatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
    
    // make circle avatars
    CALayer *layer = [cell.collectionOwnerAvatarView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:cell.collectionOwnerAvatarView.frame.size.height/2];
    
    // network type
    NSString *imageName = [itemFeed.type stringByAppendingFormat:@".png"];
    UIImage *typeImage = [UIImage imageNamed:imageName];
    [cell.typeIconView setImage:typeImage];
    
    // title and description
    [cell.itemTitle setText:itemFeed.title];
    
    [cell detectLinksInLabel:cell.itemDescription withColor:[UIColor colorWithHexString:@"#f03e56"]];
    [cell.itemDescription setText:itemFeed.description];
    [cell.itemDescription setTextAlignment:NSTextAlignmentLeft];
    [cell.itemDescription setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.itemDescription setNumberOfLines:0];
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

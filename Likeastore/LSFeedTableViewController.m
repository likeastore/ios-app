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
#import "LSItem.h"
#import "LSCollection.h"
#import "LSSimpleTableViewCell.h"

@interface LSFeedTableViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (strong, nonatomic) NSMutableDictionary *dynamicImageHeightRows;

@end

@implementation LSFeedTableViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _offscreenCells = [NSMutableDictionary dictionary];
        _dynamicImageHeightRows = [NSMutableDictionary dictionary];
    }
    
    return self;
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
        
        NSLog(@"ITEMS LOADED");
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
    LSItem *item = [[LSItem alloc] initWithDictionary:[self.items objectAtIndex:indexPath.row]];
    NSString *reuseIdentfier = item.isThumbnail ? @"thumbCell" : @"textCell";
    LSSimpleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentfier forIndexPath:indexPath];
    
    if (item.isThumbnail) {
        cell.itemThumb.contentMode = UIViewContentModeScaleAspectFill;
        cell.itemThumb.layer.borderWidth = 1.0f;
        cell.itemThumb.layer.borderColor = [UIColor colorWithHexString:@"#ddd"].CGColor;
        [cell.itemThumb setImageWithURL:[NSURL URLWithString:item.thumbnail] placeholderImage:[UIImage imageNamed:@"default-preview.png"]];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath withData:item];
    
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
    
    CGFloat dynamicDescriptionHeight = [cell.itemDescription systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    if (itemFeed.isThumbnail) {
        return dynamicDescriptionHeight + 386.0f;
    } else {
        return dynamicDescriptionHeight + 136.0f;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//}

- (void)configureCell:(LSSimpleTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withData:(LSItem *)item {
    
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
    [cell detectLinksInLabel:cell.itemDescription withColor:[UIColor colorWithHexString:@"#f03e56"]];
    [cell.itemDescription setText:item.description];
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

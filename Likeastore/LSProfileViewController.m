//
//  LSProfileViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 11.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSProfileViewController.h"
#import "LSDropdownViewController.h"
#import "LSCollectionDetailsViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSSharedUser.h"
#import "LSUser.h"
#import "LSCollection.h"
#import "LSCollectionsTableViewCell.h"
#import "LSEmptyMessageView.h"
#import "LSMenuBar.h"
#import "UIImage+Color.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

@interface LSProfileViewController ()

@property (strong, nonatomic) UIView *bgTopView;
@property (strong, nonatomic) NSMutableArray *collections;

@end

@implementation LSProfileViewController

static NSString *currentListName;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _collections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentListName = @"curating";
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"profile opened"];
    
    self.bgTopView = [[LSMenuBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [self.view addSubview:self.bgTopView];
    
    [self.avatarView.layer setMasksToBounds:YES];
    [self.avatarView.layer setCornerRadius:self.avatarView.frame.size.height/2];
    [self.avatarView.layer setBorderWidth:2.0f];
    [self.avatarView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    LSSharedUser *sharedUser = [LSSharedUser create];
    [sharedUser setDelegate:self];
    [sharedUser needsAuthorizedUser:YES];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // show activity indicator on first load
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loader setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 165.0f)];
    [self.view addSubview:loader];
    [loader startAnimating];
    
    [self getCollectionsForCurrentList:^{
        [self removeLoader:loader];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [self.curatingCountLabel setText:[NSString stringWithFormat:@"%tu", [self.collections count]]];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [[self parentViewController] parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    
    [menu.inboxButton setHidden:YES];
    [menu.searchButton setHidden:YES];
    [menu.settingsButton setHidden:NO];
    
    [menu setMenubarTitle:@"Profile"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getCollectionsForCurrentList:(void (^)())completion {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    // get collections that user owns
    if ([currentListName isEqualToString:@"curating"]) {
        [api getCollections:^(AFHTTPRequestOperation *operation, id collectionsList) {
            [self handleCollectionsData:collectionsList];
            if (completion) completion();
        } failure:nil];
        
    // get collections that user follows
    } else if ([currentListName isEqualToString:@"following"]) {
        LSUser *user = [LSSharedUser sharedUser];
        [api getCollectionsFollowedByUser:user.name success:^(AFHTTPRequestOperation *operation, id collectionsList) {
            [self handleCollectionsData:collectionsList];
            if (completion) completion();
        } failure:nil];
    }
}

- (void)handleCollectionsData:(id)collectionsList {
    [self.collections removeAllObjects];
    
    @autoreleasepool {
        if ([collectionsList count] > 0) {
            NSMutableArray *result = [[NSMutableArray alloc] init];
            for (NSDictionary *collectionData in collectionsList) {
                LSCollection *collection = [[LSCollection alloc] initWithDictionary:collectionData];
                [result addObject:collection];
            }
            
            [self.collections addObjectsFromArray:result];
            
            [result removeAllObjects];
            result = nil;
        } else if ([collectionsList count] == 0) {
            NSString *message = [currentListName isEqualToString:@"curating"] ?
            @"You have 0 collections. Use web application to create collections now." :
            @"You don't follow any collections yet. Explore them!";
            
            LSEmptyMessageView *emptyView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyMessageView" owner:self options:nil] firstObject];
            [emptyView.emptyMessageLabel setText:message];
            [self.tableView setNxEV_emptyView:emptyView];
        }
    }
    
    [self.tableView reloadData];
}

- (void)removeLoader:(UIActivityIndicatorView *)loader {
    [loader stopAnimating];
    [loader removeFromSuperview];
}

- (void)haveSharedUser:(LSUser *)user {
    [self.avatarView setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
    
    if (user.isDisplayName) {
        [self.nameLabel setText:user.displayName];
    } else {
        [self.nameLabel setText:user.name];
    }
    
    [self.followingCountLabel setText:[NSString stringWithFormat:@"%tu", user.followCollectionsCount]];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.collections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSCollection *collection = [self.collections objectAtIndex:indexPath.row];
    
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    LSCollection *collection = [self.collections objectAtIndex:indexPath.row];
    
    [(LSCollectionDetailsViewController *)segue.destinationViewController setCollection:collection];
}

- (IBAction)switchList:(UIButton *)sender {
    if (([currentListName isEqualToString:@"following"] && sender.tag == 2) ||
        ([currentListName isEqualToString:@"curating"] && sender.tag == 1)) {
        return;
    }
    currentListName = sender.tag == 2 ? @"following" : @"curating";
    [self getCollectionsForCurrentList:nil];
}

- (IBAction)backFromCollectionDetailsUnwindSegueCallback:(UIStoryboardSegue *)segue {
    LSSharedUser *sharedUser = [LSSharedUser create];
    [sharedUser needsAuthorizedUser:YES];
    [self getCollectionsForCurrentList:^{
        LSUser *user = [LSSharedUser sharedUser];
        [self.followingCountLabel setText:[NSString stringWithFormat:@"%tu", user.followCollectionsCount]];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.bgTopView.frame = CGRectMake(0.0f, 0.0f, 320.0f, -scrollView.contentOffset.y);
}

@end

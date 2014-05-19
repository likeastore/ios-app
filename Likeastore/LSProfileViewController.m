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
#import "LSMenuBar.h"
#import "UIImage+Color.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface LSProfileViewController ()

//@property (strong, nonatomic) LSUser *user;
@property (strong, nonatomic) UIView *bgTopView;
@property (strong, nonatomic) NSMutableArray *collections;

@end

@implementation LSProfileViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _collections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgTopView = [[LSMenuBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [self.view addSubview:self.bgTopView];
    
    LSSharedUser *sharedUser = [LSSharedUser create];
    [sharedUser setDelegate:self];
    [sharedUser needsAuthorizedUser];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // show activity indicator on first load
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loader setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 165.0f)];
    [self.view addSubview:loader];
    [loader startAnimating];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getCollections:^(AFHTTPRequestOperation *operation, id collectionsList) {
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
        
        [self.curatingCountLabel setText:[NSString stringWithFormat:@"%tu", [self.collections count]]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loader stopAnimating];
        [loader removeFromSuperview];
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
    // Dispose of any resources that can be recreated.
}

- (void)haveSharedUser:(LSUser *)user {
    [self.avatarView.layer setMasksToBounds:YES];
    [self.avatarView.layer setCornerRadius:self.avatarView.frame.size.height/2];
    [self.avatarView.layer setBorderWidth:2.0f];
    [self.avatarView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.avatarView setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
    
    if (user.isDisplayName) {
        [self.nameLabel setText:user.displayName];
    } else {
        [self.nameLabel setText:user.name];
    }
    
    [self.followingCountLabel setText:[NSString stringWithFormat:@"%tu", [user.followCollections count]]];
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

- (IBAction)backFromCollectionDetailsUnwindSegueCallback:(UIStoryboardSegue *)segue {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //if (scrollView.contentOffset.y < 0) {
        self.bgTopView.frame = CGRectMake(0.0f, 0.0f, 320.0f, -scrollView.contentOffset.y);
    //}
}

@end

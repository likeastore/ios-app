//
//  LSFlagModalViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 02.06.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSFlagModalViewController.h"
#import "LSLikeastoreHTTPClient.h"

@interface LSFlagModalViewController ()

@property (strong, nonatomic) NSArray *options;

@end

@implementation LSFlagModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.options = @[@"Spam", @"Inappropriate", @"Bullying", @"Self harm", @"Not interesting"];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorColor:[UIColor colorWithHexString:@"#a3a5c0" alpha:0.6f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.options count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        return 46;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flagOptionCell" forIndexPath:indexPath];
    
    [cell.textLabel setText:self.options[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    NSString *reason = self.options[indexPath.row];

    [api flagItemWithID:self.itemID withReason:reason success:nil failure:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(didFlagItemWithID:forIndexPath:)]) {
            [self.delegate didFlagItemWithID:self.itemID forIndexPath:self.itemIndexPath];
        }
    }];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  LSSettingsTableViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 11.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSSettingsTableViewController.h"
#import "LSDropdownViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSSharedUser.h"
#import "LSWebAuthViewController.h"
#import "LSNetwork.h"

#import <Underscore.m/Underscore.h>
#import <SDWebImage/SDImageCache.h>

@interface LSSettingsTableViewController ()

@end

@implementation LSSettingsTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"settings opened"];
    
    if (self.hideStatusBar) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getNetworks:^(AFHTTPRequestOperation *operation, id networks) {
        for (NSDictionary *networkData in networks) {
            LSNetwork *network = [[LSNetwork alloc] initWithDictionary:networkData];
            LSSwitch *targetSwitch = Underscore.array(self.switches).find(^BOOL(LSSwitch *networkSwitch) {
                return [networkSwitch.service isEqualToString:network.service];
            });
            if (!network.disabled) {
                [targetSwitch setOn:YES animated:YES];
            }
        }
    } failure:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [self parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    
    [menu.inboxButton setHidden:YES];
    [menu.settingsButton setHidden:YES];
    [menu.searchButton setHidden:YES];
    
    [menu setMenubarTitle:@"Settings"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.signOutCell) {
        [self signOut];
    } else if (selectedCell == self.clearCacheCell) {
        [self clearCache];
    }
}

- (void)clearCache {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearMemory];
    [cache clearDisk];
    [cache cleanDisk];
    [cache setValue:nil forKey:@"memCache"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Cache successfully cleared!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)signOut {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api logoutWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LSSharedUser unauthorizeSharedUser];
        
        //segue to login
        [self performSegueWithIdentifier:@"showLoginAfterSignOut" sender:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Sorry, you cannot sign out now, please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (IBAction)toggleSwitch:(LSSwitch *)sender {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    if (sender.isOn) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"network enabled"];
        
        [self setTargetOnSwitch:sender];
        
        if ([sender.service isEqualToString:@"dribbble"]) {
            // show dribbble find user modal
            [self performSegueWithIdentifier:@"showDribbbleConnect" sender:self];
        } else {
            // go to web auth flow
            [api connectNetwork:sender.service success:^(AFHTTPRequestOperation *operation, id responseObject) {
                LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
                [webAuthCtrl setUrlString:[responseObject objectForKey:@"authUrl"]];
                [webAuthCtrl setSettingsController:self];
                
                [self presentViewController:webAuthCtrl animated:YES completion:nil];
            } failure:nil];
        }
    } else {
        [api deleteNetwork:sender.service success:nil failure:nil];
    }
}

- (void)callNetworkConnectDissmissal {
    [self.targetOnSwitch setOn:NO animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDribbbleConnect"]) {
        [segue.destinationViewController setSettingsController:self];
    }
}

- (IBAction)closeWhenAsModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  LSFeedTableViewCell.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 01.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface LSFeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *itemThumb;
@property (weak, nonatomic) IBOutlet UIImageView *typeIconView;

@property (weak, nonatomic) IBOutlet UIImageView *collectionOwnerAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *collectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *collectionOwner;

- (void) detectLinksInLabel:(id)label withColor:(UIColor *)color;

@end

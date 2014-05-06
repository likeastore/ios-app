//
//  LSFavoritesTableViewCell.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 05.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface LSFavoritesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *itemAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *itemAuthor;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *itemTypeView;
@property (weak, nonatomic) IBOutlet UIImageView *itemThumbView;

- (void) detectLinksInLabel:(id)label withColor:(UIColor *)color;

@end

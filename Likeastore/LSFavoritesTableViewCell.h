//
//  LSFavoritesTableViewCell.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 05.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSFavoritesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *itemAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *itemAuthor;
@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *itemTypeView;

@end

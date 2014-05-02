//
//  LSSimpleTableViewCell.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 01.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSSimpleTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemDescription;
@property (strong, nonatomic) IBOutlet UIImageView *itemThumb;
@property (strong, nonatomic) IBOutlet UIImageView *typeIconView;

@property (strong, nonatomic) IBOutlet UIImageView *collectionOwnerAvatarView;
@property (strong, nonatomic) IBOutlet UILabel *collectionTitle;
@property (strong, nonatomic) IBOutlet UILabel *collectionOwner;

@end

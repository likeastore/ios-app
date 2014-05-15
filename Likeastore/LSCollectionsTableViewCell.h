//
//  LSCollectionsTableViewCell.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 15.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSCollectionsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *collectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *collectionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionDescriptionLabel;

@end

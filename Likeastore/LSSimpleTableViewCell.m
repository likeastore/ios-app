//
//  LSSimpleTableViewCell.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 01.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSSimpleTableViewCell.h"

@implementation LSSimpleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)detectLinksInLabel:(id)label withColor:(UIColor *)color {
    if ([label isKindOfClass:[TTTAttributedLabel class]]) {
        NSArray *attrKeys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, (id)kCTUnderlineStyleAttributeName, nil];
        NSArray *attrObjects = [[NSArray alloc] initWithObjects:color, [NSNumber numberWithInt:kCTUnderlineStyleThick], nil];
        NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:attrObjects forKeys:attrKeys];
        [label setLinkAttributes:linkAttributes];
        [label setEnabledTextCheckingTypes:NSTextCheckingTypeLink];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

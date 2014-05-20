//
//  LSSwitch.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 20.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSSwitch.h"

@implementation LSSwitch

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSString *)service {
    switch (self.tag) {
        case 0:
            return @"facebook";
            break;
            
        case 1:
            return @"twitter";
            break;
            
        case 2:
            return @"instagram";
            break;
            
        case 3:
            return @"youtube";
            break;
            
        case 4:
            return @"vimeo";
            break;
            
        case 5:
            return @"dribbble";
            break;
            
        case 6:
            return @"behance";
            break;
            
        case 7:
            return @"github";
            break;
            
        case 8:
            return @"gist";
            break;
            
        case 9:
            return @"stackoverflow";
            break;
            
        case 10:
            return @"tumblr";
            break;
            
        case 11:
            return @"pocket";
            break;
            
        case 12:
            return @"flickr";
            break;
            
        default:
            return nil;
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

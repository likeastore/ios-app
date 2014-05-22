//
//  LSCircleView.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 21.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSCircleView.h"

@implementation LSCircleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithHexString:@"#F03D56"].CGColor));
    CGContextFillPath(ctx);
}

@end

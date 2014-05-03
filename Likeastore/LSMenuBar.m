//
//  LSMenuBar.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSMenuBar.h"

@implementation LSMenuBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // Drawing vertical likeastore navy gradient
    UIColor *navyOne = [UIColor colorWithHexString:@"#43c2c2"];
    UIColor *navyTwo = [UIColor colorWithHexString:@"#49d1b3"];
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([navyOne CGColor]);
    NSMutableArray *colors = [[NSMutableArray alloc] initWithObjects:(id)[navyOne CGColor], (id)[navyTwo CGColor], nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize size = self.bounds.size;
    CGPoint start = CGPointMake(0.0f, 0.0f);
    CGPoint end = CGPointMake(size.width, 0.0f);
    CGContextDrawLinearGradient(context, gradient, start, end, kNilOptions);
}

@end

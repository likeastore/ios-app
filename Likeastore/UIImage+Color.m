//
//  UIImage+Color.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 14.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithGradientColors {
    UIColor *navyOne = [UIColor colorWithHexString:@"#43c2c2"];
    UIColor *navyTwo = [UIColor colorWithHexString:@"#49d1b3"];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, 50.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([navyOne CGColor]);
    NSMutableArray *colors = [[NSMutableArray alloc] initWithObjects:(id)[navyOne CGColor], (id)[navyTwo CGColor], nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
    CGPoint start = CGPointMake(0.0f, 0.0f);
    CGPoint end = CGPointMake(320.0f, 0.0f);
    CGContextDrawLinearGradient(context, gradient, start, end, kNilOptions);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

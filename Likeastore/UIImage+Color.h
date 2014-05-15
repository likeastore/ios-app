//
//  UIImage+Color.h
//  Likeastore
//
//  Created by Dmitri Voronianski on 14.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithGradientColors;

@end

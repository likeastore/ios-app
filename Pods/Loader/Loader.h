//
//  Loader.h
//  Loader
//
//  Created by Company Name on 12/09/13.
//  Copyright (c) 2013 Company Name. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Loader : UIView

@property (nonatomic, assign) BOOL renderStatic;
@property (nonatomic, strong) UIColor *tint;
@property (nonatomic, strong) CALayer *tintLayer;

@property (nonatomic, strong) UILabel *lblProgressMsg;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

- (void)renderLayerWithView:(UIView*)superview;

-(void)displayLoadingView:(NSString *)strMessage;
-(void)hideLoadingView;
+ (Loader*) defaultLoader;

@end

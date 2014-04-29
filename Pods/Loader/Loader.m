//
//  Loader.m
//  Loader
//
//  Created by Company Name on 12/09/13.
//  Copyright (c) 2013 Company Name. All rights reserved.
//

#define kLoaderWidth 100
#define kLoaderHeight 100
#define kProgressMsg @"Please wait"
//#define kColor [UIColor colorWithRed:47.0/255.0 green:142.0/255.0 blue:252.0/255.0 alpha:1.0]
#define kColor [UIColor whiteColor]

#define kScreenshotCompression 0.01
#define kBlurRadius 1.0
#define kCornerRadius 8.0
#define kRenderFps 30.0
#define kTintColorAlpha 0.8

#import "Loader.h"
#import "UIImage+BoxBlur.h"
#import <QuartzCore/QuartzCore.h>

@interface LoaderManager : NSObject

@property (nonatomic, strong) NSMutableArray *views;

/* Returns the global instance */
+ (id)sharedManager;

/* Register and deregister views */
- (void)registerView:(Loader*)view;
- (void)deregisterView:(Loader*)view;

@end

@implementation Loader

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tintLayer = [[CALayer alloc] init];
        self.tintLayer.frame = self.bounds;
        self.tintLayer.opacity = kTintColorAlpha;

        self.tint = [UIColor blackColor];
        [self.layer addSublayer:self.tintLayer];

        self.clipsToBounds = YES;
        self.layer.cornerRadius = kCornerRadius;

        _lblProgressMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 100, 21)];
        _lblProgressMsg.text = kProgressMsg;
        _lblProgressMsg.backgroundColor = [UIColor clearColor];
        _lblProgressMsg.font = [UIFont fontWithName:@"Roboto-Medium" size:16];
        _lblProgressMsg.textAlignment = NSTextAlignmentCenter;
        _lblProgressMsg.textColor = kColor;
        _lblProgressMsg.numberOfLines = 1;
        _lblProgressMsg.adjustsFontSizeToFitWidth = YES;
        //_lblProgressMsg.adjustsLetterSpacingToFitWidth = YES;
        [self addSubview:_lblProgressMsg];

        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.frame = CGRectMake(32, 20, 37, 37);
        _indicator.hidesWhenStopped = YES;
        [_indicator startAnimating];
        [_indicator setColor:kColor];
        [self addSubview:_indicator];

        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

-(void)displayLoadingView:(NSString *)strMessage{
    self.lblProgressMsg.text = strMessage;
    if(!self.superview){
        UIWindow *mainWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [mainWindow addSubview:self];
        self.alpha = 0.0;
        mainWindow.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
    }
}

-(void)hideLoadingView{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

    UIWindow *mainWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    mainWindow.userInteractionEnabled = YES;
}

#pragma mark Init

+ (Loader*) defaultLoader {
	__strong static Loader *defaultLoader = nil;
	if (!defaultLoader) {
		defaultLoader = [[Loader alloc] init];
	}
	return defaultLoader;
}

-(id)init{
    CGRect centerFrame;
    centerFrame.size.width = kLoaderWidth;
    centerFrame.size.height = kLoaderHeight;
    return [self initWithFrame:centerFrame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self renderLayerWithView:newSuperview];
    [self setCenter:newSuperview.center];
}

#pragma mark - Properties

- (void)setRenderStatic:(BOOL)renderStatic{
    _renderStatic = renderStatic;
    if (renderStatic)
        [[LoaderManager sharedManager] deregisterView:self];
    else
        [[LoaderManager sharedManager] registerView:self];
}

- (void)setTint:(UIColor*)tint{
    _tint = tint;
    self.tintLayer.backgroundColor = _tint.CGColor;
    [self.tintLayer setNeedsDisplay];
}

- (void)didMoveToSuperview{
    if (nil != self.superview){
        if (!self.renderStatic)
            [[LoaderManager sharedManager] registerView:self];
    }else{
        [[LoaderManager sharedManager] deregisterView:self];
    }
}

- (void)renderLayerWithView:(UIView*)superview{
    //get the visible rect
    CGRect visibleRect = [superview convertRect:self.frame toView:self];
    visibleRect.origin.y += self.frame.origin.y;
    visibleRect.origin.x += self.frame.origin.x;

    //hide all the blurred views from the superview before taking a screenshot
    CGFloat alpha = self.alpha;
    [self toggleBlurViewsInView:superview hidden:YES alpha:alpha];

    //Render the layer in the image context
    //UIGraphicsBeginImageContextWithOptions(visibleRect.size, NO, 1.0);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextTranslateCTM(context, -visibleRect.origin.x, -visibleRect.origin.y);
    //CALayer *layer = superview.layer;
    //[layer renderInContext:context];

    //show all the blurred views from the superview before taking a screenshot
    [self toggleBlurViewsInView:superview hidden:NO alpha:alpha];

    __block UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        //takes a screenshot of that portion of the screen and blurs it
        //helps w/ our colors when blurring
        //feel free to adjust jpeg quality (lower = higher perf)
        NSData *imageData = UIImageJPEGRepresentation(image, kScreenshotCompression);
        image = [[UIImage imageWithData:imageData] drn_boxblurImageWithBlur:kBlurRadius];

        dispatch_sync(dispatch_get_main_queue(), ^{
            //update the layer content
            self.layer.contents = (id)image.CGImage;
        });
    });
}

- (void)toggleBlurViewsInView:(UIView*)view hidden:(BOOL)hidden alpha:(CGFloat)originalAlpha{
    for (UIView *subview in view.subviews)
        if ([subview isKindOfClass:Loader.class])
            subview.alpha = hidden ? 0.f : originalAlpha;
}

@end

#pragma mark - LoaderManager implementation

@implementation LoaderManager

+ (id)sharedManager{
    static dispatch_once_t pred;
    static LoaderManager *shared = nil;

    dispatch_once(&pred, ^{
        shared = [[LoaderManager alloc] init];
    });

    return shared;
}

- (id)init{
    if (self = [super init])
        self.views = [@[] mutableCopy];

    return self;
}

- (void)registerView:(Loader*)view{
    if (![self.views containsObject:view]) [self.views addObject:view];
    [self refresh];
}

- (void)deregisterView:(Loader*)view{
    [self.views removeObject:view];
    [self refresh];
}

- (void)refresh{
    if (!self.views.count) return;
    for (Loader *view in self.views)
        [view renderLayerWithView:view.superview];

    double delayInSeconds = self.views.count * (1/kRenderFps);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self refresh];
    });
}

@end
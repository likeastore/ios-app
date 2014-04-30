//
//  LSDropdownViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSDropdownViewController.h"
#import <HexColors/HexColor.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <FontAwesomeKit/FAKFoundationIcons.h>

@interface LSDropdownViewController ()

@end

@implementation LSDropdownViewController

CAShapeLayer *openMenuShape;
CAShapeLayer *closedMenuShape;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    FAKFontAwesome *listIcon = [FAKFontAwesome barsIconWithSize:22.0f];
    [self.menuButton setTitle:nil forState:UIControlStateNormal];
    [self.menuButton setImage:[listIcon imageWithSize:CGSizeMake(22.0f, 22.0f)] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self customizeMenu];
    // Do any additional setup after loading the view.
}

- (void)customizeMenu {
    UIColor *menuColor = [UIColor colorWithHexString:@"#e0dede"];
    UIColor *menuColorHover = [UIColor whiteColor];
    float icon_size = 24.0f;
    
    for (UIButton *button in self.buttons) {
        if ([button.titleLabel.text isEqualToString:@"Home"]) {
            FAKFoundationIcons *homeIcon = [FAKFoundationIcons homeIconWithSize:icon_size];
            
            [homeIcon addAttribute:NSForegroundColorAttributeName value:menuColor];
            [button setImage:[homeIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateNormal];
            
            [homeIcon addAttribute:NSForegroundColorAttributeName value:menuColorHover];
            [button setImage:[homeIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateHighlighted];
        }
        
        if ([button.titleLabel.text isEqualToString:@"Favorites"]) {
            FAKFoundationIcons *heartIcon = [FAKFoundationIcons heartIconWithSize:icon_size];
            
            [heartIcon addAttribute:NSForegroundColorAttributeName value:menuColor];
            [button setImage:[heartIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateNormal];
            
            [heartIcon addAttribute:NSForegroundColorAttributeName value:menuColorHover];
            [button setImage:[heartIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateHighlighted];
        }
        
        // align image and text
        [button sizeToFit];
        button.frame = CGRectMake(0.0f, 132.0f, 0.0f, 0.0f);
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 132.0f - button.titleLabel.frame.size.width/2.4f, 0.0f, 0.0f);
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f);
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        // set button states
        [button setTitleColor:menuColor forState:UIControlStateNormal];
        [button setTitleColor:menuColorHover forState:UIControlStateHighlighted];
        [button setBackgroundImage:[self imageWithColor:[UIColor colorWithHexString:@"#303040"]] forState:UIControlStateHighlighted];
        
        // toggle bottom border on taps
        [button addTarget:self action:@selector(hideBottomBorder:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(showBottomBorder:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(showBottomBorder:) forControlEvents:UIControlEventTouchDragOutside];
        
        // add bottom border
        if (button != self.buttons.lastObject) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 46.0f, button.frame.size.width-16.0f, 1.6f)];
            lineView.tag = 1;
            lineView.backgroundColor = [UIColor colorWithHexString:@"#303040"];
            [button addSubview:lineView];
        }
    }
}

- (void)hideBottomBorder:(UIButton *)button {
    for (UIView *border in button.subviews) {
        if (border.tag == 1) {
            [border setHidden:YES];
        }
    }
}

- (void)showBottomBorder:(UIButton *)button {
    for (UIView *border in button.subviews) {
        if (border.tag == 1 && [border isHidden]) {
            [border setHidden:NO];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawOpenLayer {
    openMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = self.menubar.frame.size.height;
    int width = self.menubar.frame.size.width;
    float trianglePlacement = 0.046;
    int triangleDirection = -1; // 1 for down, -1 for up.
    int triangleSize = 5;
    int trianglePosition = trianglePlacement*width;
    
    // The path for the triangle (showing that the menu is open).
    UIBezierPath *triangleShape = [[UIBezierPath alloc] init];
    [triangleShape moveToPoint:CGPointMake(trianglePosition, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+triangleSize, height+triangleDirection*triangleSize)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition, height)];
    
    [openMenuShape setPath:triangleShape.CGPath];
    [openMenuShape setFillColor:[self.menu.backgroundColor CGColor]];
    [openMenuShape setBounds:CGRectMake(0.0f, 0.0f, height+triangleSize, width)];
    [openMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [openMenuShape setPosition:CGPointMake(0.0f, 0.0f)];
}

- (void)drawClosedLayer {
    closedMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = self.menubar.frame.size.height;
    int width = self.menubar.frame.size.width;
    
    [closedMenuShape setBounds:CGRectMake(0.0f, 0.0f, height, width)];
    [closedMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [closedMenuShape setPosition:CGPointMake(0.0f, 0.0f)];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

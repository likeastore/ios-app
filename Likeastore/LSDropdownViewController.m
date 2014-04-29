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
    
    [self customizeMenu];
    // Do any additional setup after loading the view.
}

- (void)customizeMenu {
    UIColor *iconColor = [UIColor colorWithHexString:@"#eee"];
    float icon_size = 24;
    
    for (UIButton *button in self.buttons) {
        if ([button.titleLabel.text isEqualToString:@"Home"]) {
            FAKFoundationIcons *homeIcon = [FAKFoundationIcons homeIconWithSize:icon_size];
            [homeIcon addAttribute:NSForegroundColorAttributeName value:iconColor];
            
            UIImage *iconImage = [homeIcon imageWithSize:CGSizeMake(icon_size, icon_size)];
            [button setImage:iconImage forState:UIControlStateNormal];
        }
        
        if ([button.titleLabel.text isEqualToString:@"Favorites"]) {
            FAKFoundationIcons *starIcon = [FAKFoundationIcons starIconWithSize:icon_size];
            [starIcon addAttribute:NSForegroundColorAttributeName value:iconColor];
            
            UIImage *iconImage = [starIcon imageWithSize:CGSizeMake(icon_size, icon_size)];
            [button setImage:iconImage forState:UIControlStateNormal];
        }
        
        // align image and text
        button.frame = CGRectMake(0, 125.0, 0, 0);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 125.0 - button.titleLabel.frame.size.width/2.4, 0, 0);
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        // add bottom border
        if (button != self.buttons.lastObject) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45.0f, button.frame.size.width, 1.6f)];
            lineView.backgroundColor = [UIColor colorWithHexString:@"#303040"];
            [button addSubview:lineView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
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
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0, height)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition, height)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition+triangleSize, height+triangleDirection*triangleSize)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [borderPath addLineToPoint:CGPointMake(width, height)];
    
    [openMenuShape setPath:borderPath.CGPath];
    [openMenuShape setBounds:CGRectMake(0.0f, 0.0f, height+triangleSize, width)];
    [openMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [openMenuShape setPosition:CGPointMake(0.0f, 0.0f)];
}

- (void) drawClosedLayer {
    closedMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = self.menubar.frame.size.height;
    int width = self.menubar.frame.size.width;
    
    // The path for the border (just a straight line)
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0, height)];
    [borderPath addLineToPoint:CGPointMake(width, height)];
    
    [closedMenuShape setPath:borderPath.CGPath];
    [closedMenuShape setBounds:CGRectMake(0.0f, 0.0f, height, width)];
    [closedMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [closedMenuShape setPosition:CGPointMake(0.0f, 0.0f)];
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

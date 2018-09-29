//
//  UDNavigationController.m
//  test
//
//  Created by UDi on 15-1-7.
//  Copyright (c) 2015年 Mango Media Network Co.,Ltd. All rights reserved.
//

#import "UDNavigationController.h"

@implementation UDNavigationController
@synthesize alphaView;
-(id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        CGRect frame = self.navigationBar.frame;
        alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height + (IS_IPHONE_X ? 44:20))];
        alphaView.backgroundColor = kMainColor;
        [self.view insertSubview:alphaView belowSubview:self.navigationBar];
        
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, IS_IPHONE_X ? 88 : 64);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.layer.masksToBounds = YES;
        
    }
    return self;
}
-(void)setAlph{
    if (_changing == NO) {
        _changing = YES;
        if (alphaView.alpha == 0.0 ) {
            alphaView.alpha = 1.0;
            _changing = NO;
            
        }else{
            
            alphaView.alpha = 0.0;
            _changing = NO;
        }
    }
    
    
}

@end

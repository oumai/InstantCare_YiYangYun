//
//  KMImageTwoLeftTextView.h
//  InstantCare
//
//  Created by Frank He on 9/8/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMImageTwoRightTextView : UIView

-(instancetype)initWithImage:(UIImage*)image
                rightTopText:(NSString*)topText
                   topFont:(NSInteger)font
             rightBottomText:(NSString*)bottomText
                  bottomFont:(NSInteger)font;


@end

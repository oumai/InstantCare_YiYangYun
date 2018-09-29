//
//  KMHeaderView.h
//  InstantCare
//
//  Created by mac on 2016/11/26.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMHeaderView;
@protocol  KMHeaderViewDelegate<NSObject>

@optional
- (void)headerViewButtonClick;

@end

@interface KMHeaderView : UIView

+ (instancetype)viewFromXib;

@property (nonatomic, weak) id<KMHeaderViewDelegate> delegate;

@end

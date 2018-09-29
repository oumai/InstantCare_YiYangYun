//
//  KMWebViewVC.h
//  InstantCare
//
//  Created by km on 16/6/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMWebViewVC : UIViewController

/**
 *  HTML链接, 如果是"HTML_type_help"需要特殊处理
 */
@property(nonatomic, copy) NSString * htmURL;
/**
 *  导航栏标题
 */
@property(nonatomic, copy) NSString * navigationTitle;

@end

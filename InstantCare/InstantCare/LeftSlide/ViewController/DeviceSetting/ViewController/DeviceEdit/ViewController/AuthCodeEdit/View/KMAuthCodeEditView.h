//
//  KMAuthCodeEditView.h
//  InstantCare
//
//  Created by km on 16/6/15.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMCustomTextField.h"

@interface KMAuthCodeEditView : UIView

/**
 *  旧的认证码
 */
@property(nonatomic,strong)KMCustomTextField * oldAuthCode;

/**
 *  新的认证码
 */
@property(nonatomic,strong)KMCustomTextField * nowAuthCode;

/**
 *  确定
 */
@property(nonatomic,strong)UIButton * okButton;

/**
 *  重置
 */
@property(nonatomic,strong)UIButton * resetButton;


@end

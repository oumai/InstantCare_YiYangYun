//
//  KMNetworkResModel.h
//  InstantCare
//
//  Created by bruce-zhu on 15/12/11.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  通用解析模型
 */
@interface KMNetworkResModel : NSObject

@property (nonatomic, assign) int errorCode;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) id content;

@end

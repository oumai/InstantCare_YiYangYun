//
//  KMPersonModel.m
//  InstantCare
//
//  Created by 朱正晶 on 16/5/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMPersonModel.h"
#import "MJExtension.h"
@implementation KMPersonModel

+ (void)load {
    [KMPersonModel mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"list" : @"KMPersonDetailModel"
                 };
    }];
}

@end

@implementation KMPersonDetailModel

@end

//
//  KMPersonModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/24.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMPersonModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end


@interface KMPersonDetailModel : NSObject

@property (nonatomic, copy) NSString *NickName;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, copy) NSString *realName;

@property (nonatomic, copy) NSString *memberIdNumber;

@property (nonatomic, assign) long long birthday;



@end
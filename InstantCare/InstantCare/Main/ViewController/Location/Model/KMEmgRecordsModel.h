//
//  KMEmgRecordsModel.h
//  InstantCare
//
//  Created by 朱正晶 on 16/5/20.
//  Copyright © 2016年 omg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  紧急救援
 */
@interface KMEmgRecordsModel : NSObject

@property (nonatomic, strong) NSArray *list;

@end

@interface KMEmgRecordsDetailModel : NSObject

@property (nonatomic, copy) NSString *address;

@property (nonatomic, assign) long long emgDate;

@property (nonatomic, assign) double gpsLat;

@property (nonatomic, assign) double gpsLng;

@property (nonatomic, assign) BOOL cellSelected;

//s89基站(LBS) s85(GPS)
@property (nonatomic, copy) NSString *type;

@end



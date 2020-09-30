//
//  BloodPressModel.h
//  YiJiaRendaYaoFang
//
//  Created by apple on 16/12/28.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BloodPressModel : NSObject

@property (nonatomic, copy)NSString *high_pressure;   // 高压
@property (nonatomic, copy)NSString *low_pressure;    // 低压
@property (nonatomic, copy)NSString *heart_rate;      // 心率
@property (nonatomic, copy)NSString *member_id;       // 用户id
@property (nonatomic, copy)NSString *heartrate_range; // 心率范围
@property (nonatomic, copy)NSString *check_date;


@end

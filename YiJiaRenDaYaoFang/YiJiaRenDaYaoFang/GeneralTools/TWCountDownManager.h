//
//  CountDownManager.h
//  CellCountDown
//
//  Created by herobin on 16/9/11.
//  Copyright © 2016年 herobin. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 使用单例
#define kCountDownManager [TWCountDownManager manager]
/// 倒计时的通知
#define kCountDownNotification @"CountDownNotification"

@interface TWCountDownManager : NSObject

/// 时间差(单位:秒)
@property (nonatomic, assign) NSInteger timeInterval;

/// 使用单例
+ (instancetype)manager;

/// 开始倒计时
- (void)start;

/// 取消定时器
- (void)invalidate;

/// 刷新倒计时
- (void)reload;

@end

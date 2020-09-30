//
//  NSTimer+Extention.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2018/12/26.
//  Copyright © 2018 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NSTimerBlock)(void);
typedef void(^NSCountDownCallback)(NSUInteger countdown);

@interface NSTimer (Extention)

+ (void)invalidate:(NSTimer *)timer;

/**
 设置定时器
 
 @param interval 定时间隔
 @param repeats 是否重复
 @param callback 回调
 @return 返回定时器
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                              timerCallback:(NSTimerBlock)callback;

/**
 设置定时器
 
 @param interval 定时间隔
 @param repeats 是否重复
 @param limitCount 超时次数
 @param countdownCallback 倒计时回调
 @param timerEndCallback 倒计时结束回调
 @return 返回定时器
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                 limitCount:(NSInteger)limitCount
                          countdownCallback:(NSCountDownCallback)countdownCallback
                           timerEndCallback:(NSTimerBlock)timerEndCallback;
@end

NS_ASSUME_NONNULL_END

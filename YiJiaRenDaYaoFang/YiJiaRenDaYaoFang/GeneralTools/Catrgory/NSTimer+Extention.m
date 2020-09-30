//
//  NSTimer+Extention.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2018/12/26.
//  Copyright © 2018 TW. All rights reserved.
//

#import "NSTimer+Extention.h"
#import <objc/runtime.h>

@interface NSTimer ()

@property (nonatomic, assign) NSUInteger currentCount;

@end

@implementation NSTimer (Extention)

static NSString *ageKey = @"ageKey";

- (NSUInteger)currentCount {
    NSNumber *numVaue = objc_getAssociatedObject(self, &ageKey);
    return [numVaue integerValue];
}

- (void)setCurrentCount:(NSUInteger)currentCount {
    objc_setAssociatedObject(self, &ageKey, @(currentCount), OBJC_ASSOCIATION_ASSIGN);
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                              timerCallback:(NSTimerBlock)timerCallback {
    
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(onTimerUpdateBlock:)
                                          userInfo:[timerCallback copy]
                                           repeats:repeats];
}

+ (void)onTimerUpdateBlock:(NSTimer *)timer {

    NSTimerBlock block = timer.userInfo;
    if (block) {
        block();
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    repeats:(BOOL)repeats
                                 limitCount:(NSInteger)limitCount
                           countdownCallback:(NSCountDownCallback)countdownCallback
                              timerEndCallback:(NSTimerBlock)timerEndCallback
                                 {
    NSDictionary *userInfo = @{@"countdownCallback" : [countdownCallback copy],
                               @"timerEndCallback"  : [timerEndCallback copy],
                               @"limitCount"        : @(limitCount)};
    
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(beyoudLimitTime:)
                                          userInfo:userInfo
                                           repeats:repeats];
}

+ (void)beyoudLimitTime:(NSTimer *)timer {
//    static NSUInteger currentCount = 0;
    
    NSDictionary *userInfo = timer.userInfo;
    NSCountDownCallback countdownCallback = userInfo[@"countdownCallback"];
    NSTimerBlock timerEndCallback = userInfo[@"timerEndCallback"];
    NSNumber *count = userInfo[@"limitCount"];
    
    timer.currentCount++;
    NSLog(@"timer.currentCount = %lu",(unsigned long)timer.currentCount);
    if (timer.currentCount >= count.integerValue) {
        if (timerEndCallback) {
            timerEndCallback();
            [NSTimer invalidate:timer];
            timer.currentCount = 0;
        }
    }else {
        if (countdownCallback) {
            countdownCallback(timer.currentCount);
        }
    }
}

+ (void)invalidate:(NSTimer *)timer {
    // 取消定时器
    [timer invalidate];
    timer = nil;
}

@end

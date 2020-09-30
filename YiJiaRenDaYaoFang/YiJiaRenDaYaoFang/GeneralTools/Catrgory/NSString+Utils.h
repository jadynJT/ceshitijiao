//
//  NSString+Utils.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2017/8/12.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

// 截取URL中的参数
- (NSMutableDictionary *)getURLParameters;

// 判断字符串是否为网址
- (BOOL)isUrlString;

// json解析
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

// 弹框提示
+ (void)alert:(NSString *)tipStr;

@end

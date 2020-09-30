//
//  Utility.h
//  YiJiaRenDaYaoFang
//
//  Created by admin on 16/4/28.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (BOOL)isIPhone4;

+ (BOOL)isIPhone5;

+ (BOOL)isIPhone6;

+ (BOOL)isIPhone6Plus;

+ (NSString *)lanchImageInch:(NSString *)keySize;

//JS桥接
+ (void)webViewJavascriptBridge:(id)bridge
                    handlerName:(NSString *)handlerName
             webViewJSCallBlock:(void(^)(id data, WVJBResponseCallback responseCallback))webViewJSCallBlock;

//跳转 下个页面
+ (void)gotoNextVC:(UIViewController *)vc fromViewController:(UIViewController *)viewCtr;

//判断字符串为空
+ (BOOL) isBlankString:(NSString *)string;

//网页加载失败处理
- (void)catchError:(NSError *)error webView:(QqcWebView *)webview;

//超时处理
- (void)onTimeOutAction:(QqcWebView *)webview;

//正则判断是否手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

//判断是否为数字
+ (BOOL)validateNumber:(NSString*)number;

//将yyyy-MM-dd HH:mm 格式时间转换成时间戳
+ (long)changeTimeToTimeSp:(NSString *)timeStr;

//将时间戳转换成NSDate，不知道哪国时间
+ (NSDate *)changeSpToTime:(NSString*)spStr;

//将时间戳转换成北京时间
+ (NSDate*)zoneChange:(NSString*)spString;

//将NSDate按yyyy-MM-dd HH:mm 格式时间输出
+ (NSString*)dateToString:(NSDate *)date;

//获取时间段
- (NSDictionary *)getTheTimeBucket:(NSDate *)currentDate;

//改变textfield
+ (void)changeColor:(UITextField *)textField;

//比较两个日期的大小
+(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;

//当地时间转换格林治时间
+ (NSDate *)getLocalDateFromatAnDate:(NSDate *)anyDate;

+ (NSInteger)getIndex:(NSString *)str;

@end

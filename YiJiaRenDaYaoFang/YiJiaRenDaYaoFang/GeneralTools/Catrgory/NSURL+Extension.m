//
//  NSURL+Extension.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/6/19.
//  Copyright © 2019 TW. All rights reserved.
//

#import "NSURL+Extension.h"

@interface NSURL ()

@end

@implementation NSURL (Extension)

/**
 *  打开URL链接
 *  @param showFailTip 是否显示错误提示
 */
- (void)openUrlWithIsShowFailTip:(BOOL)showFailTip {
    if ([[UIApplication sharedApplication] canOpenURL:self])
    {// 跳转成功
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:self options:@{} completionHandler:^(BOOL success){}];
        }
        else {
            [[UIApplication sharedApplication] openURL:self];
        }
    }else
    {// 跳转失败
        if (showFailTip) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"未检测到应用，请安装后重试"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end

//
//  UIHelper.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/8/14.
//  Copyright © 2019 TW. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper

/**
 * 跳转到某个App中
 * @param url App链接(App标识符)
 * @param showOpenFailTip 是否显示失败提示
 *
 */
+ (void)openUrl:(NSURL *)url
showOpenFailTip:(BOOL)showOpenFailTip {
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {// 跳转成功
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success){}];
        }
        else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }else
    {// 跳转失败
        if (showOpenFailTip) {
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

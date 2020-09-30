//
//  UIHelper.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/8/14.
//  Copyright © 2019 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIHelper : NSObject

/**
 *  跳转到某个App中
 * @param url App链接(App标识符)
 * @param showOpenFailTip 是否显示失败提示
 *
 */
+ (void)openUrl:(NSURL *)url
showOpenFailTip:(BOOL)showOpenFailTip;

@end

NS_ASSUME_NONNULL_END

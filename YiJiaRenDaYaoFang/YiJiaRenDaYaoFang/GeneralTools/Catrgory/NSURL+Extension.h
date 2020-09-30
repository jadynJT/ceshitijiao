//
//  NSURL+Extension.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/6/19.
//  Copyright © 2019 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Extension)

/**
 *  打开URL链接
 *  @param showFailTip 是否显示错误提示
 */
- (void)openUrlWithIsShowFailTip:(BOOL)showFailTip;

@end

NS_ASSUME_NONNULL_END

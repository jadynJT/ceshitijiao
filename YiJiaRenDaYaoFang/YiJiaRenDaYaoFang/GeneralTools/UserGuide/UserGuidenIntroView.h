//
//  UserGuidenIntroView.h
//  86YYZX
//
//  Created by apple on 2017/8/18.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserGuidenIntroView : UIView

/*
 * 判断是否需要显示新功能介绍页
 *
 */
+ (BOOL)firstLaunchAfterNewVersionInstalled;


/*
 * 获取plist文件中的图片数组
 *
 */
+ (NSArray *)introImageNamesForCurrentVersion;


/*
 * 显示新功能介绍页
 * @prama images       图片数组
 * @prama dismissBlock 退出的block
 */
+ (UserGuidenIntroView *)showWithImages:(NSArray<NSString *> *)images dismissBlock:(void (^)(void))dismissBlock;

@end

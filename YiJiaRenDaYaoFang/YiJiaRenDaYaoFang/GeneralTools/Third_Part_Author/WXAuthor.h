//
//  WXAuthor.h
//  ActivityViewController
//
//  Created by JS1-ZJT on 16/7/8.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WXAuthor : NSObject

@property (nonatomic, strong) UIViewController *viewcontroller;

+(instancetype)shareInstance;

//handurl
-(BOOL)handleOpenURL:(NSURL *)url;

-(void)WeChatOAuth:(NSString *)WXID;

#pragma mark ----微信支付
- (void)wechatPay:(NSDictionary *)dict;

// 判断微信是否安装
- (BOOL)isWXAppInstalled;

// 分享回调
@property (nonatomic, copy)void(^shareRespBlock)(enum WXErrCode errCode);

// 授权回调
@property (nonatomic, copy)void(^authorRespBlock)(enum WXErrCode errCode);

// 支付回调
@property (nonatomic, copy)void(^payRespBlock)(enum WXErrCode errCode);

@end

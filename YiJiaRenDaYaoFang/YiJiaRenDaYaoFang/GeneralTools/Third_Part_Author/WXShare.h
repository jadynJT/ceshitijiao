//
//  WXShare.h
//  86YYZX
//
//  Created by apple on 2018/4/29.
//  Copyright © 2018年 jztw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

typedef enum : NSUInteger {
    mediaWebpageObject = 0,  // 多媒体消息为网页
    mediaImageObject   = 1,  // 多媒体消息为图片
} WXMeidaObject;

@interface WXShare : NSObject

+ (instancetype)shareInstance;

/**
 * 朋友圈、好友分享
 * @param url 链接
 * @param title 标题
 * @param description 描述
 * @param imgurl 图片链接
 * @param sceneType 0 朋友对话 1 朋友圈
 * @param mediaType 媒体类型
 */
- (void)shareWithUrl:(NSString *)url
               title:(NSString *)title
         description:(NSString *)description
              imgurl:(NSString *)imgurl
           sceneType:(NSInteger)sceneType
           mediaType:(WXMeidaObject)mediaType;


/**
 * 小程序分享（目前小程序只能分享给好友）
 * @param url 低版本网页链接(微信低版本只能通过链接分享)
 * @param title 标题
 * @param description 描述
 * @param userName   小程序原始id
 * @param pagePath   小程序页面的路径
 * @param hdImageUrl 小程序新版本的预览图
 */
- (void)shareMinProgramWithUrl:(NSString *)url
                         title:(NSString *)title
                   description:(NSString *)description
                      userName:(NSString *)userName
                      pagePath:(NSString *)pagePath
                    hdImageUrl:(NSString *)hdImageUrl;

@end

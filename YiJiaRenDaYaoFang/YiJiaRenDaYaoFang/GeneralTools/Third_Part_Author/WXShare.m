//
//  WXShare.m
//  86YYZX
//
//  Created by apple on 2018/4/29.
//  Copyright © 2018年 jztw. All rights reserved.
//

#import "WXShare.h"
#import "UIImage+Compress.h"

@implementation WXShare

static WXShare *wxShareManager = nil;
static dispatch_once_t onceToken;
+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        wxShareManager = [[WXShare alloc] init];
    });
    return wxShareManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [WXShare shareInstance];
}

// PDSingleInstanceDef.h

//#define single_interface(class)  + (class *)share##class;
//
//// .m
//// \ 代表下一行也属于宏
//// ## 是分隔符
//#define single_implementation(class) \
//static class *_instance; \
// \
//+ (class *)share##class \
//{ \
//    if (_instance == nil) { \
//        _instance = [[self alloc] init]; \
//    } \
//    return _instance; \
//} \
// \
//+ (id)allocWithZone:(NSZone *)zone \
//{ \
//    static dispatch_once_t onceToken; \
//    dispatch_once(&onceToken, ^{ \
//        _instance = [super allocWithZone:zone]; \
//    }); \
//    return _instance; \
//}
//


- (void)shareWithUrl:(NSString *)url
               title:(NSString *)title
         description:(NSString *)description
              imgurl:(NSString *)imgurl
           sceneType:(NSInteger)sceneType
           mediaType:(WXMeidaObject)mediaType
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        UIImage *thumbImg;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[imgurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        if (data == nil) {
            thumbImg = [UIImage imageNamed:@"AppIcon29x29"];
        }else {//进行缩略图片大小检测(KB)
            thumbImg = [UIImage compressImage:[UIImage imageWithData:data] toByte:32*1024]; // 缩略图不超过32k
        }

                NSMutableString *webUrl = [NSMutableString stringWithFormat:@"%@",url];
                if (![url hasPrefix:@"http"]) {
                    webUrl = [NSMutableString stringWithFormat:@"https://%@",url];
                }
        
                if ([webUrl containsString:@"\""]) {// 当包含""时移除
                    [webUrl deleteCharactersInRange:NSMakeRange(0, 1)];
                    [webUrl deleteCharactersInRange:NSMakeRange(webUrl.length-1, 1)];
                }
        
        id mediaObject;
        switch (mediaType) {
            case mediaWebpageObject: {// 内容为网页
                WXWebpageObject *webpageObject = [WXWebpageObject object];
                webpageObject.webpageUrl = url;
                mediaObject = webpageObject;
            }
                break;
            case mediaImageObject: {// 内容为图片
                WXImageObject *imageObject = [WXImageObject object];
                imageObject.imageData = [self base64TransformImageData:url];
                mediaObject = imageObject;
            }
            default:
                break;
        }
        
        WXMediaMessage *message = [self wxMediaMessageWithTitle:title
                                                    description:description
                                                    mediaObject:mediaObject
                                                     thumbImage:thumbImg];
        
        SendMessageToWXReq *req = [self sendMessageToWXReqWithText:nil
                                                      mediaMessage:message
                                                             bText:NO
                                                             scene:(int)sceneType];
        
        [WXApi sendReq:req];
        
    }else {
        [self shareFailAlert]; // 分享失败提示框
    }
}

- (void)shareMinProgramWithUrl:(NSString *)url
                         title:(NSString *)title
                   description:(NSString *)description
                      userName:(NSString *)userName
                      pagePath:(NSString *)pagePath
                    hdImageUrl:(NSString *)hdImageUrl {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        WXMiniProgramObject *object = [WXMiniProgramObject object];
        object.withShareTicket = YES;
        object.miniProgramType = WXMiniProgramTypeRelease;
        object.webpageUrl      = url;
        object.userName        = userName;
        object.path            = pagePath;
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:hdImageUrl]];
        
        UIImage *image = [UIImage compressImage:[UIImage imageWithData:data] toByte:128*1024];
        
        object.hdImageData = image.imageData;
        
        WXMediaMessage *message = [self wxMediaMessageWithTitle:title
                                                    description:description
                                                    mediaObject:object
                                                     thumbImage:[UIImage imageNamed:@"AppIcon29x29"]];
        
        SendMessageToWXReq *req = [self sendMessageToWXReqWithText:nil
                                                      mediaMessage:message
                                                             bText:NO
                                                             scene:WXSceneSession];
        [WXApi sendReq:req];
    }else {
        [self shareFailAlert]; // 分享失败提示框
    }
}

- (WXMediaMessage *)wxMediaMessageWithTitle:(NSString *)title
                                description:(NSString *)description
                                mediaObject:(id)mediaObject
                                 thumbImage:(UIImage  *)thumbImage
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title       = title;
    message.description = description;
    message.mediaObject = mediaObject;
    [message setThumbImage:thumbImage];
    return message;
}

- (SendMessageToWXReq *)sendMessageToWXReqWithText:(NSString *)text
                                      mediaMessage:(WXMediaMessage *)message
                                             bText:(BOOL)bText
                                             scene:(enum WXScene)scene
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    // 分享到好友 或者 朋友圈
    req.scene = scene;
    req.bText = bText;
    if (bText) {
        req.text = text; // 只显示单文本
    }else {
        req.message = message;
    }
    return req;
}

// base64转成二进制图片
- (NSData *)base64TransformImageData:(NSString *)imageUrl {
    // base64字符转成图片
    NSString *urlStr = imageUrl;
    if ([imageUrl hasPrefix:@"data:image/png;base64,"]) {
        urlStr = [imageUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"data:image/png;base64,"] withString:@""]; // 去掉"data:image/png;base64,"前缀
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:urlStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

- (void)shareFailAlert
{// 分享失败提示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败" message:@"分享平台 [微信] 尚未安装客户端！无法进行分享！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end

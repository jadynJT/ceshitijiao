//
//  WXAuthor.m
//  ActivityViewController
//
//  Created by JS1-ZJT on 16/7/8.
//  Copyright © 2016年 JS1-ZJT. All rights reserved.
//

#import "WXAuthor.h"
#import "AFNetworking.h"
#import "WechatAuthSDK.h"
#import <CommonCrypto/CommonDigest.h>

@interface WXAuthor()<WXApiDelegate>

@end

@implementation WXAuthor

static WXAuthor *wxAuthorManager = nil;
static dispatch_once_t onceToken;
+(instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        wxAuthorManager = [[WXAuthor alloc] init];
    });
    return wxAuthorManager;
}

// handurl
-(BOOL)handleOpenURL:(NSURL *)url{
    if ([WXApi handleOpenURL:url delegate:self]) {
        NSLog(@"WX-成功处理跳转");
        return YES;
    }else{
        NSLog(@"WX-处理失败");
        return NO;
    }
}

#pragma mark ----微信授权
- (void)WeChatOAuth:(NSString *)WXID
{
    //    [WXApi registerApp:WXID];
    [self wechatLogin];        // 微信登录
    //    [kCountDownManager start]; // 启动倒计时管理
}

#pragma mark ----微信登录
- (void)wechatLogin
{
    //    if (![self isWXAppInstalled])
    //    {// 未安装微信
    //        NSLog(@"未安装微信客户端，授权失败");
    //        return;
    //    }
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"LaoBaiXingYaoFang";
    //    [WXApi sendReq:req];
    
    if ([self isWXAppInstalled]) {// 有安装调起微信登录
        [WXApi sendReq:req];
    }else {// 未安装跳到网页版登录
        [WXApi sendAuthReq:req viewController:self.viewcontroller delegate:self];
    }
}

#pragma mark ----微信支付
- (void)wechatPay:(NSDictionary *)dict
{//调起微信支付
    
    NSLog(@"dictdict = %@",dict);
    
    NSString *stamp  = [dict objectForKey:@"timestamp"];
    
    NSLog(@"stamp.intValue = %d",(UInt32)stamp.integerValue);
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    [WXApi sendReq:req];
}

#pragma mark ----判断微信是否安装
- (BOOL)isWXAppInstalled
{
    if ([WXApi isWXAppInstalled])
    {// 安装微信
        NSLog(@"安装了微信客户端");
        return YES;
    }else
    {// 未安装微信
        NSLog(@"未安装微信客户端，授权失败");
        return NO;
    }
}

#pragma mark - 倒计时通知回调
//- (void)countDownNotification
//{
////    [[NSUserDefaults standardUserDefaults] setObject:@(date_seconds) forKey:@"current_time"];
//    
//    NSTimeInterval accessTokenTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"getAccessToken_time"] doubleValue];
//    
//    NSDate *nowDate =  [NSDate new];
//    NSDate *countDownDate = [NSDate dateWithTimeIntervalSince1970:accessTokenTime];
//    NSTimeInterval value = [nowDate timeIntervalSinceDate:countDownDate]; // 计算出时间戳的差值
//    
//    NSTimeInterval period = 7200.0; //设置时间间隔(7200秒)
//    
//    if (value >= period) {
//        NSLog(@"valuevalue = %f",value);
//        [self refresh_token];
//        [[TWCountDownManager manager] invalidate];
//    }
//}

//**< //
//    1、获取到code
//    2、带上code获取token和openID
//    3、根据token和openID来获取用户的相关信息
//>**//

#pragma mark ----微信授权回调
- (void)onResp:(BaseResp *)resp
{
    //微信登录
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        NSLog(@"授权登录");
        
        @try {
            switch (resp.errCode) {
                case WXSuccess:
                {
                    //成功
                    SendAuthResp *authResp = (SendAuthResp *)resp;
                    
                    //1、获取到code
                    NSString *code = authResp.code;
                    [self getWeChatOpenId:code];
                    
                    
                    NSLog(@"微信登录-授权登录成功");
                }
                    break;
                case WXErrCodeUserCancel:
                {
                    //用户取消
                    self.authorRespBlock(WXErrCodeUserCancel);
                    //                    NSLog(@"微信登录-用户取消登录");
                }
                    break;
                case WXErrCodeSentFail:
                {
                    self.authorRespBlock(WXErrCodeSentFail);
                    //                    NSLog(@"微信登录-发送失败");
                }
                    break;
                case WXErrCodeAuthDeny:
                {
                    //授权失败
                    self.authorRespBlock(WXErrCodeAuthDeny);
                    //                    NSLog(@"微信登录-授权失败");
                }
                    break;
                default:
                {
                    //微信不支持
                    self.authorRespBlock(WXErrCodeUnsupport);
                    //                    NSLog(@"微信登录-微信不支持");
                }
                    break;
            }
        } @catch (NSException *e) {
            NSLog(@"%@",[NSString stringWithFormat:@"WXCode_Exception = %@",e]);
        }
    }
    
    // 微信支付
    if ([resp isKindOfClass:[PayResp class]]) {
        @try {
            switch (resp.errCode) {
                case WXSuccess:
                {//成功
                    self.payRespBlock(WXSuccess);
                    NSLog(@"微信支付-支付成功");
                }
                    break;
                case WXErrCodeUserCancel:
                {//用户取消
                    self.payRespBlock(WXErrCodeUserCancel);
                    NSLog(@"微信支付-用户退出支付");
                }
                    break;
                default:
                {//支付失败
                    self.payRespBlock(WXErrCodeSentFail);
                    NSLog(@"微信支付-支付失败");
                }
                    break;
            }
        } @catch (NSException *e) {
            NSLog(@"%@",[NSString stringWithFormat:@"WXCode_Exception = %@",e]);
        }
    }
    
    //微信分享/收藏
    //    if ([resp isKindOfClass:[SendMessageToWXResp class]]){
    //        SendMessageToWXResp *sendResp = (SendMessageToWXResp *)resp;
    //
    //        NSLog(@"微信分享");
    //
    //        @try {
    //            switch (sendResp.errCode) {
    //                case WXSuccess:
    //                {//成功
    //                    NSLog(@"微信分享-成功");
    //                    self.shareRespBlock(WXSuccess);
    //                }
    //                    break;
    //                case WXErrCodeUserCancel:
    //                {//用户取消
    //                    NSLog(@"微信分享-用户取消分享");
    //                    self.shareRespBlock(WXErrCodeUserCancel);
    //                }
    //                    break;
    //                case WXErrCodeSentFail:
    //                {//发送失败
    ////                    NSLog(@"微信分享-发送失败");
    //                    self.shareRespBlock(WXErrCodeSentFail);
    //                }
    //                    break;
    //                case WXErrCodeAuthDeny:
    //                {//授权失败
    ////                    NSLog(@"微信分享-授权失败");
    //                    self.shareRespBlock(WXErrCodeAuthDeny);
    //                }
    //                    break;
    //                default:
    //                {
    //                    //微信不支持
    ////                    NSLog(@"微信分享-微信不支持");
    //                    self.shareRespBlock(WXErrCodeUnsupport);
    //                }
    //                    break;
    //            }
    //        } @catch (NSException *e) {
    //            NSLog(@"%@",[NSString stringWithFormat:@"WXShare_Exception = %@",e]);
    //        }
    //    }
    
}

//openid = oQ3OE0dEdNYLTGtPdtRmmp0m2MgU
//unionid = o2gOlwxNjzN7SShV19p3CIxy4jSA;

//2、通过code获取access_token，refresh_token，openid，unionid
- (void)getWeChatOpenId:(NSString *)code
{
#pragma mark-------
    //**< 通过code获取access_token的接口:
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code >**//
    
    NSString *url = [NSString stringWithFormat:@"%@/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WX_BASE_URL,WXDoctor_App_ID,WXDoctor_App_Secret,code];
    //利用GCD来获取对应的token和openID
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data){
                NSDictionary *tokenDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"tokenDic = %@",tokenDic);
                
#pragma mark------记录下获取到token的时间 并转成秒
                //当前时间转成秒
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                long long int date_seconds = (long long int)time;
                NSLog(@"date\n%lld", date_seconds);
                
                /////
                NSString *accessToken = tokenDic[@"access_token"];    // 获取到access_token
                //                NSString *refresh_token = tokenDic[@"refresh_token"]; // 获取refresh_token
                //                NSString *expires_in = tokenDic[@"expires_in"];       // token的生命周期
                NSString *openID = tokenDic[@"openid"];               // 获取到openid
                //                NSString *unionid = tokenDic[@"unionid"];             // 获取到unionid
                
#pragma mark-----储存
                //                NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                //                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                //储存 获取到access_token 的时间
                //                [[NSUserDefaults standardUserDefaults] setObject:@(date_seconds) forKey:@"getAccessToken_time"];
                
                //存储：access_token、refresh_token、openid
                //                [[NSUserDefaults standardUserDefaults] setObject:accessToken   forKey:WX_ACCESS_TOKEN];
                //                [[NSUserDefaults standardUserDefaults] setObject:refresh_token forKey:WX_REFRESH_TOKEN];
                //                [[NSUserDefaults standardUserDefaults] setObject:expires_in    forKey:WX_EXPIRES_IN];
                //                [[NSUserDefaults standardUserDefaults] setObject:openID  forKey:WX_OPEN_ID];
                //                [[NSUserDefaults standardUserDefaults] setObject:unionid forKey:WX_UNION_ID];
                //                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //                self.authorRespBlock(WXSuccess);
                
                // 监听通知
                //                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countDownNotification) name:kCountDownNotification object:nil];
                
                //                [self refresh_token];
                
                // 请求微信用户基本信息
                [self getUserInfo:accessToken openID:openID tokenDic:tokenDic];
            }
        });
        
    });
    
}

//3、获取用户相关信息
-(void)getUserInfo:(NSString *)accessToken
            openID:(NSString *)openID
          tokenDic:(NSDictionary *)tokenDic;
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"%@/userinfo?access_token=%@&openid=%@",WX_BASE_URL,accessToken,openID];
    
    //利用GCD来获取用户信息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                // 合并两个字典
                NSMutableDictionary *mutabledict = [NSMutableDictionary dictionary];
                [mutabledict addEntriesFromDictionary:tokenDic];
                [mutabledict addEntriesFromDictionary:userDic];
                
                [[NSUserDefaults standardUserDefaults] setObject:mutabledict forKey:WX_USER_INFO];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSLog(@"mutableDict = %@",mutabledict);
                
                self.authorRespBlock(WXSuccess);
            }
        });
    });
}

//检验授权凭证是否有效
//-(void)checkAuthor{
//    
//    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
//    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
//    
//    if (access_token.length == 0 && openID.length == 0) {
//        //重新进行授权登录
//        return;
//    }
//    
//    NSString *refreshUrlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/auth?access_token=%@&openid=%@", access_token, openID];
//    NSURL *URL = [NSURL URLWithString:refreshUrlStr];
//    
//    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
//    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    [sessionManager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSLog(@"responseObject = %@", responseObject);
//        
//        NSDictionary *checkDict = [NSDictionary dictionaryWithDictionary:responseObject];
//        
//        // 如果checkDict[@"errmsg"]为“ok”，则access_token有效
//        if ([checkDict[@"errmsg"] isEqualToString:@"ok"]) {
//            
//        }
//        else{
//            [self refresh_token];  //刷新token
//        }
//        
//        NSLog(@"json----%@", responseObject);
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);
//    }];
//}

//刷新token 如果refreshToken过期则进行授权登录
//- (void)refresh_token
//{
//    NSString *refreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_REFRESH_TOKEN];
//    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
//    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
//    
//    if (access_token.length > 0 && openID.length > 0) {
//        NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",WX_BASE_URL, WXDoctor_App_ID, refreshToken];
//        NSURL *URL = [NSURL URLWithString:refreshUrlStr];
//        
//        ////////    ////////
//        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
//        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
//        [sessionManager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            
//            NSLog(@"请求reAccess的response = %@", responseObject);
//            
//            NSDictionary *refreshDict = [NSDictionary dictionaryWithDictionary:responseObject];
//            // 刷新重新获取access_token
//            NSString *reAccessToken = refreshDict[WX_ACCESS_TOKEN];
//            
//            #pragma mark------记录下获取到token的时间 并转成秒
//            //当前时间转成秒
//            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//            long long int date_seconds = (long long int)time;
//            NSLog(@"date\n%lld", date_seconds);
//            
//            // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
//            if (reAccessToken.length > 0) {
//                //储存获取到access_token的时间
//                [[NSUserDefaults standardUserDefaults] setObject:@(date_seconds) forKey:@"getAccessToken_time"];
//                
//                // 更新access_token、refresh_token、open_id
//                [[NSUserDefaults standardUserDefaults] setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
//                [[NSUserDefaults standardUserDefaults] setObject:refreshDict[WX_OPEN_ID] forKey:WX_OPEN_ID];
//                [[NSUserDefaults standardUserDefaults] setObject:refreshDict[WX_REFRESH_TOKEN] forKey:WX_REFRESH_TOKEN];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                [kCountDownManager start]; // 启动倒计时管理
//            }
//            else{
//                //重新进行授权登录
//                [self wechatLogin];
//            }
//            
//            NSLog(@"json----%@", responseObject);
//            
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);
//            [kCountDownManager start]; // 启动倒计时管理
//        }];
//    }
//    else{
//       //重新进行授权登录
//    }
//}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end

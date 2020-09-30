//
//  AuthManager.h
//  HireAssistant
//
//  Created by zohar on 16/9/24.
//  Copyright © 2016年 sunshine. All rights reserved.
//

#ifndef AuthManager_h
#define AuthManager_h


//** 微信 **//
#define WX_BASE_URL          @"https://api.weixin.qq.com/sns"      // 微信平台地址
#define WXDoctor_App_ID      @"wx979567a297da047b"                 // 注册微信时的AppID
#define WXDoctor_App_Secret  @"21de5f1a26ed27670a4836fa6e60c53b"   // 注册时得到的AppSecret
#define WX_ACCESS_TOKEN      @"access_token"                       // accese_token
#define WX_REFRESH_TOKEN     @"refresh_token"                      // refresh_token
#define WX_EXPIRES_IN        @"expires_in"                         // access_token接口调用凭证超时时间，单位（秒）
#define WX_USER_INFO         @"userInfo"                           // 微信用户信息
#define WXPatient_App_ID     @"wxbd02bfeea4292***"
#define WXPatient_App_Secret @"4a788217f363358276309ab655707***"
#define WX_OPEN_ID           @"openid"
#define WX_UNION_ID          @"unionid"

#define APP_ID               @"1330119271"                          // itunes connect上的appID

#ifdef WaiCe
#define BAIDU_MAP_APP_KEY     @"FM7yHhGlutMsNeeOS3MYfF0zhOVm71T9"
#else
#define BAIDU_MAP_APP_KEY     @"4iv6Urll7aGKZbnCgoeA1R3Mk7Grw0iO"
#endif

//FM7yHhGlutMsNeeOS3MYfF0zhOVm71T9    亿家人健康
//4iv6Urll7aGKZbnCgoeA1R3Mk7Grw0iO    demo亿家人健康

#endif /* AuthManager_h */

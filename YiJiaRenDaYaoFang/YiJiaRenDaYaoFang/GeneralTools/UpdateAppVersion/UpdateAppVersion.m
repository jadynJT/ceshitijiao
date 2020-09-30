//
//  TWUpdateAppVersion.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2017/8/14.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import "UpdateAppVersion.h"

@implementation UpdateAppVersion

static UpdateAppVersion *updateAppManager = nil;
static dispatch_once_t onceToken;
+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        updateAppManager = [[UpdateAppVersion alloc] init];
    });
    return updateAppManager;
}

+ (void)hs_updateWithAPPID:(NSString *)appid block:(void(^)(NSString *currentVersion,NSString *storeVersion,NSString *openUrl, BOOL isUpdate))block{
    // 1、先获取当前工程项目版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = infoDic[@"CFBundleShortVersionString"];
    
    // 2、从网络获取appStore版本号
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",appid]]] returningResponse:nil error:nil];
    if (response == nil) {
        NSLog(@"你没有连接网络哦");
        return;
    }
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"hsUpdateAppError:%@",error);
        return;
    }
    
    NSArray *array = appInfoDic[@"results"];
    
    if (array.count < 1) {
        NSLog(@"此APPID为未上架的APP或者查询不到");
        return;
    }
    
    NSDictionary *dic = array[0];
    NSString *appStoreVersion = dic[@"version"];
    
    // 3、打印版本号
    // 4、设置版本号
    currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (currentVersion.length == 2) {
        currentVersion = [currentVersion stringByAppendingString:@"0"];
    }else if (currentVersion.length == 1){
        currentVersion = [currentVersion stringByAppendingString:@"00"];
    }
    appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (appStoreVersion.length == 2) {
        appStoreVersion = [appStoreVersion stringByAppendingString:@"0"];
    }else if (appStoreVersion.length == 1){
        appStoreVersion = [appStoreVersion stringByAppendingString:@"00"];
    }
    
    //5当前版本号小于商店版本号,就更新
    if([currentVersion floatValue] < [appStoreVersion floatValue])
    {
        UpdateAppVersion *updateAppVersion = [UpdateAppVersion shareInstance];
        updateAppVersion.appVersionInfo = @{@"storeVersion":dic[@"version"],
                                            @"openUrl":[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appid],
                                            @"isUpdate":@YES
                                            };
        block(currentVersion,dic[@"version"],[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appid],YES);
    }else{
        //        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
        block(currentVersion,dic[@"version"],[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appid],NO);
    }
}

@end

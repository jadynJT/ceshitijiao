//
//  WebViewJSBridgeViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/5/23.
//  Copyright © 2019 TW. All rights reserved.
//

#import "WebViewJSBridgeViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "TWBaseNavigationController.h"
#import "LinkSkipViewController.h"
#import <Contacts/Contacts.h>
#import "NSURL+Extension.h"
#import "Utility.h"
#import "WXShare.h"
#import "WXAuthor.h"
#import "NSString+Utils.h"
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface WebViewJSBridgeViewController ()<QRCodeReaderDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) QRCodeReaderViewController *reader;
@property (nonatomic, strong) BMKLocationService  *locService;
@property (nonatomic, strong) BMKGeoCodeSearch    *geocodesearch;
@property (nonatomic, strong) NSMutableDictionary *cacheDict;
@property (nonatomic,   copy) NSString *isSaved;
@property (nonatomic,   copy) NSString *latitude;  // 纬度
@property (nonatomic,   copy) NSString *longitude; // 经度
@property (nonatomic, assign) BOOL isRegJS; // 是否已经注册了JS

@end

@implementation WebViewJSBridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self onResp];        // 登录、支付回调
    [self startLocation]; // 开始定位
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isRegJS) {
        [self regJSApi]; // webview与JS交互
    }
    
    if ([_isSaved isEqualToString:@"0"]) {
        [self.webView setReLoad]; // 重新刷新
    }
}

- (void)regJSApi
{
    self.isRegJS = YES; // 设置为已注册
    
    __weak typeof(self) weakself = self;
    // 调用扫码方法
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"scancode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        NSLog(@"调用扫码方法");
        [weakself scannerClick];
    }];
    
    // 调用分享方法
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"wxsharedcode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        NSLog(@"调用分享方法");
        [weakself shared:data];
    }];
    
    // 分享小程序
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"wxminprogramcode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        NSLog(@"调用分享小程序");
        [weakself wxWinProgramClick:data];
    }];
    
    // 测量页面
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"measureCode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself gotoMeasurePage:data];
    }];
    
    // 会员搜索页面
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"memberSearchCode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself gotoSearchVC:data];
    }];
    
    // 退出登录 清理缓存
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"loginOutCode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        NSLog(@"退出登录");
        [weakself loginOutAction];
    }];
    
    // 清除缓存
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"removeCache" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself removeCache];
    }];
        
    // 经纬度
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"getLngLat" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [self startLocation];
    }];
    
    // 写入缓存
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"setCache" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        weakself.cacheDict = (NSMutableDictionary *)data;
    }];

    // 读取缓存
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"getCache" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        responseCallback(weakself.cacheDict);
    }];
    
    // 读取通讯录
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"setContact" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself getAuthor];
    }];
    
    // 打开应用设置
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"openSetting" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself openSettings];
    }];
    
    // 微信登录
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"wxlogincode" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself wxLogin];
    }];
    
    // 微信支付
    [Utility webViewJavascriptBridge:self.bridge handlerName:@"wxPayhandle" webViewJSCallBlock:^(id data, WVJBResponseCallback responseCallback){
        [weakself wxPay:data];
    }];
}

#pragma mark - 扫码
- (void)scannerClick
{
    static QRCodeReaderViewController *reader = nil;
    static TWBaseNavigationController    *nav = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        reader = [[QRCodeReaderViewController alloc] init];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
        nav = [[TWBaseNavigationController alloc] initWithRootViewController:reader];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        reader.fd_prefersNavigationBarHidden = YES; //隐藏导航栏
    });
    reader.delegate = self;
    [reader setCompletionWithBlock:^(NSString *result){}];
    self.reader = reader;
    
    [self presentViewController:nav animated:YES completion:^{
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted ||
            authStatus == AVAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"" delegate:self cancelButtonTitle:@"" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }];
}

#pragma mark - QRCodeReaderDelegate
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [self QRCodeResult:result];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reader:(QRCodeReaderViewController *)reader didImgPickerResult:(NSString *)result {
    [self QRCodeResult:result];
}

#pragma mark - 二维码/条形码识别结果
- (void)QRCodeResult:(NSString *)result {
    if ([result isUrlString]) {// 为链接网址
        if ([result containsString:URL_DOMAIN_NAME]) {// 同一域名下直接跳转
            [self dismissViewControllerAnimated:YES completion:^{
                [self.webView loadRequestWithString:result];
            }];
        }else {// 不同域名做另外处理
            LinkSkipViewController *lsvc = [[LinkSkipViewController alloc] init];
            [self.reader.navigationController pushViewController:lsvc animated:YES];
            lsvc.result = result;
        }
    }else {
        [self dismissViewControllerAnimated:YES completion:^{
            NSString *urlStr = [NSString stringWithFormat:@"%@/xcode/decode?code=%@",WEB_URL,result];
            [self.webView loadRequestWithString:urlStr];
        }];
    }
}

#pragma mark - 微信朋友或朋友圈分享
- (void)shared:(id)data
{
    if ([[data objectAtIndex:5] integerValue] == mediaImageObject) {
        [self contentCapture:data];
    }else {
        [[WXShare shareInstance] shareWithUrl:[data objectAtIndex:0] title:[data objectAtIndex:1] description:[data objectAtIndex:2] imgurl:[data objectAtIndex:3] sceneType:[[data objectAtIndex:4] integerValue] mediaType:[[data objectAtIndex:5] integerValue]];
    }
}

#pragma mark - 微信小程序分享
- (void)wxWinProgramClick:(id)data
{// 小程序分享
    [[WXShare shareInstance] shareMinProgramWithUrl:[data objectAtIndex:0] title:[data objectAtIndex:1] description:[data objectAtIndex:2] userName:[data objectAtIndex:3] pagePath:[data objectAtIndex:4] hdImageUrl:[data objectAtIndex:5]];
}

#pragma mark - 屏幕截取
- (void)contentCapture:(id)data
{// 屏幕截取
    __weak typeof(self) weakself = self;
    [self.webView contentCaptureCompletionHandler:^(UIImage *capturedImage) {
        NSData *imgData = UIImageJPEGRepresentation(capturedImage, 1.0);
        NSString *encodedImgStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        [[WXShare shareInstance] shareWithUrl:encodedImgStr title:[data objectAtIndex:1] description:[data objectAtIndex:2] imgurl:[data objectAtIndex:3] sceneType:[[data objectAtIndex:4] integerValue] mediaType:[[data objectAtIndex:5] integerValue]];
        
        // 调用前端接口，恢复webView顶部导航栏
        [weakself.bridge callHandler:@"wxsharedcode" data:@"" responseCallback:^(id responseData){}];
    }];
}

#pragma mark - 测量页面
- (void)gotoMeasurePage:(id)data {
    UIViewController *viewcontroller;
    self.isSaved = [NSString stringWithFormat:@"%@",data];
    
    if ([self.isSaved isEqualToString:@"1"]) {
        viewcontroller = [[MeasurePageViewController alloc] init];
    }else {
        viewcontroller = [[SlowDiseaseMemberViewController alloc] init];
    }
    [Utility gotoNextVC:viewcontroller fromViewController:self];
}

#pragma mark - 会员搜索页面
- (void)gotoSearchVC:(id)data {
    UIViewController *viewcontroller;
    self.isSaved = [NSString stringWithFormat:@"%@",data];
    
    if ([self.isSaved isEqualToString:@""]) {
        viewcontroller = [[MeasurePageViewController alloc] init];
    }else {
        viewcontroller = [[SlowDiseaseMemberViewController alloc] init];
    }
    [Utility gotoNextVC:viewcontroller fromViewController:self];
}

#pragma mark - 退出登录
- (void)loginOutAction {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    //退出登录
    [self.webView loadRequestWithString:URL_LOGINOUT];
}

#pragma mark - 缓存清理
- (void)removeCache {
    if ([[[UIDevice currentDevice] systemVersion] intValue] > 8)
    {   // iOS8之后使用
        NSArray *types = @[WKWebsiteDataTypeMemoryCache,WKWebsiteDataTypeDiskCache];
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateForm = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateForm completionHandler:^{}];
    }else
    {   // iOS8之前使用
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

#pragma mark - 读取通讯录
// 1. 获取权限
- (void)getAuthor {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
            if (error) {
                NSLog(@"授权失败");
                [self.bridge callHandler:@"setContact" data:@(-1) responseCallback:^(id responseData){}];
            }else {
                NSLog(@"成功授权");
                [self openContact];
            }
        }];
    }
    else if(status == CNAuthorizationStatusRestricted) {
        NSLog(@"用户拒绝");
        [self showAlertViewAboutNotAuthorAccessContact];
    }
    else if (status == CNAuthorizationStatusDenied) {
        NSLog(@"用户拒绝");
        [self showAlertViewAboutNotAuthorAccessContact];
    }
    else if (status == CNAuthorizationStatusAuthorized) // 已经授权
    {// 有通讯录权限 -- 进行下一步操作
        [self openContact];
    }
}

// 2. 有通讯录权限 --> 进入下一步操作
- (void)openContact {
    // 获取指定的字段,并不是要获取所有字段，需要指定具体的字段
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    NSMutableArray *mutableArr = [NSMutableArray array];
    
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        // 拼接姓名
        NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
        
        NSArray *phoneNumbers = contact.phoneNumbers;
        
        NSMutableArray *phoneNumArray = [NSMutableArray array];
        
        for (CNLabeledValue *labelValue in phoneNumbers) {
            // 遍历一个人名下的多个电话号码
            CNPhoneNumber *phonesNumber = labelValue.value;
            
            NSString *string = phonesNumber.stringValue;
            
            // 去掉电话中的特殊字符
            string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"-"   withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"("   withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@")"   withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" "   withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@" "   withString:@""];
            
            [phoneNumArray addObject:string];
            
            NSLog(@"姓名=%@, 电话号码是=%@", nameStr, string);
        }
        
        NSDictionary *dict = @{@"name":nameStr,@"phoneNumber":phoneNumArray};
        [mutableArr addObject:dict];
    }];
    
    [self.bridge callHandler:@"setContact" data:mutableArr responseCallback:^(id responseData){}];
}

#pragma mark - 提示没有通讯录权限
- (void)showAlertViewAboutNotAuthorAccessContact {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[infoDictionary objectForKey:@"CFBundleDisplayName"]
                                          message:@"需要访问通讯录，请您授权"
                                          preferredStyle: UIAlertControllerStyleAlert];
    
    // 去授权
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"去授权" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        // UIApplicationOpenSettingsURLString 适用于iOS8及以上系统
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [url openUrlWithIsShowFailTip:NO];
    }];
    
    [OKAction setValue:[UIColor redColor] forKey:@"_titleTextColor"]; // 设置字体颜色
    
    // 取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alertController addAction:cancelAction];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 定位
- (void)startLocation {
    NSLog(@"进入普通定位态");
    self.locService = [[BMKLocationService alloc] init];
    self.locService.desiredAccuracy = kCLLocationAccuracyBest;
    self.locService.delegate = self;
    [self.locService startUserLocationService];
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
    self.geocodesearch.delegate = self;
}

/**
 *  用户方向更新后，会调用此函数
 *  @param userLocation  新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {}

/**
 *  用户位置更新后，会调用此函数
 *  @param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    // 纬度、经度
    NSLog(@"didUpdateUserLocation lat %f,long %f\n",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    //地理反编码
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag) {
        NSLog(@"反geo检索发送成功");
        [self.locService stopUserLocationService]; // 关闭定位服务
        
        self.longitude = [NSString stringWithFormat:@"%.6f",userLocation.location.coordinate.longitude]; // 经度
        self.latitude  = [NSString stringWithFormat:@"%.6f",userLocation.location.coordinate.latitude];  // 纬度
        
        NSDictionary *setLngLat = @{@"longitude":self.longitude,
                                    @"latitude":self.latitude};
        [self.bridge callHandler:@"setLngLat" data:setLngLat responseCallback:^(id responseData) {
            NSLog(@"定位回调：%@",responseData); }];
    }else {
        // 当弱网或者无网情况下，会出现授权失败，所以重启引擎
        BMKMapManager *mapManager = [[BMKMapManager alloc] init];
        [mapManager start:BAIDU_MAP_APP_KEY generalDelegate:nil];
        NSLog(@"反geo检索发送失败");
    }
}

/**
 *  在地图View停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {}

/**
 *  定位失败后，会调用此函数
 *  @param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"定位失败");
    NSDictionary *setLngLat = @{@"lon gitude":@(locationFail),
                                @"latitude" :@(locationFail)};
    
    [self.bridge callHandler:@"setLngLat" data:setLngLat responseCallback:^(id responseData) {
        NSLog(@"定位失败回调：%@",responseData); }];
}

#pragma mark - 地理反编码的delegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"address:%@----%@",result.addressDetail.city,result.address);
    //addressDetail:   层次化地址信息
    //address:         地址名称
    //businessCircle:  商圈名称
    //location:        地址坐标
    //poiList:         地址周边POI信息，成员类型为BMKPoiInfo
}

#pragma mark - 打开应用设置
- (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [url openUrlWithIsShowFailTip:NO];
}

#pragma mark - 微信登录
- (void)wxLogin {
    [WXAuthor shareInstance].viewcontroller = self;
    [[WXAuthor shareInstance] WeChatOAuth:WX_APPKEY];
}

#pragma mark - 微信支付
- (void)wxPay:(id)data {
    if (![[WXAuthor shareInstance] isWXAppInstalled]) {
        [NSString alert:@"您未安装微信客户端"]; // 弹框提醒
    }else {
        [[WXAuthor shareInstance] wechatPay:data];
    }
}

#pragma mark - 分享、登录的回调
- (void)onResp {

    __weak typeof(self) weakSelf = self;
    // 微信登录
    [WXAuthor shareInstance].authorRespBlock = ^(enum WXErrCode errCode) {
        switch (errCode) {
            case WXSuccess: {
                // 成功
                NSDictionary *userInfoDic = [[NSUserDefaults standardUserDefaults] objectForKey:WX_USER_INFO];
                
                [weakSelf.bridge callHandler:@"setOpenid" data:userInfoDic responseCallback:^(id responseData){}];
                NSLog(@"微信登录-授权登录成功");
            }
                break;
            case WXErrCodeUserCancel: {
                // 用户取消
            }
                break;
            case WXErrCodeSentFail: {
                // 发送失败
            }
                break;
            case WXErrCodeAuthDeny: {
                //授权失败
            }
                break;
            default: {
                //微信不支持
            }
                break;
        }
    };
    
    // 微信支付
    [WXAuthor shareInstance].payRespBlock = ^(enum WXErrCode errCode) {
        switch (errCode) {
            case WXSuccess: {// 支付成功
                NSLog(@"微信支付-支付成功");
                
                [weakSelf.bridge callHandler:@"jumpurl" data:@(WXSuccess) responseCallback:^(id responseData){ NSLog(@"调用完JS后的回调：%@",responseData); }];
            }
                break;
            case WXErrCodeUserCancel: {// 用户取消支付
                NSLog(@"微信支付-用户取消支付");
                
                [weakSelf.bridge callHandler:@"jumpurl" data:@(WXErrCodeUserCancel) responseCallback:^(id responseData){}];
            }
                break;
            default: {// 支付失败
                NSLog(@"微信支付-微信支付失败");
                
                [weakSelf.bridge callHandler:@"jumpurl" data:@(WXErrCodeSentFail) responseCallback:^(id responseData){}];
            }
                break;
        }
    };
}

@end

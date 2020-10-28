
//  MainVC.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/1/20.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "MainVC.h"
#import "WXAuthor.h"
#import "iPhoneInfo.h"
#import "ACETelPrompt.h"
#import "SVProgressHUD.h"
#import "UserGuidenIntroView.h"
#import "AFNetworking.h"
#import "NSString+Utils.h"
#import "NSTimer+Extention.h"
#import "LocationManager.h"
#import "UpdateAppVersion.h"
#import "TopView.h"
#import "WXShare.h"
#import "UIHelper.h"

@interface MainVC ()<WXApiDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIImageView *bgImgView;

@property (strong, nonatomic) UIButton *countdownBtn;    // 倒计时按钮
@property (strong, nonatomic) NSTimer *timerJump;        // 跳转计时器
@property (strong, nonatomic) NSTimer *timeOut;          // 超时计时器

@property (assign, nonatomic) BOOL isFirstLoad;          // 是否第一次加载
@property (assign, nonatomic) BOOL isCheckVersion;       // 检查版本
@property (assign, nonatomic) BOOL isDispalyTopView;

@property (strong, nonatomic) TopView  *topView;

@property (copy,   nonatomic) NSString *isSaved;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configBgView]; // 显示蒙版
    
    NSLog(@"heiei");
    NSLog(@"添加到当前内容是是是");
    
    NSLog(@"添加1");
    NSLog(@"添加2");
    
    NSLog(@"查看11");
}

#pragma mark - 初始化
- (TopView *)topView {
    if (!_topView) {
        CGFloat marginY = 0;
        if (iphoneX) marginY = 44;
        
        _topView = [[TopView alloc] initWithFrame:CGRectMake(0, marginY, Screen_width, 44)];
        _topView.backgroundColor = [UIColor whiteColor];
        _topView.hidden = YES;
        
        __weak typeof(self) weakself = self;
        self.topView.returnBlock = ^{
            [weakself.webView setGoBack]; // 设置页面回退
        };
    }
    return _topView;
}

- (void)addButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(aaa:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)aaa:(UIButton *)sender {
    
}

- (UIButton *)countdownBtn {
    if (!_countdownBtn) {
        CGFloat topOrigin = 25;
        if (iphoneX) topOrigin = 35;
        _countdownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _countdownBtn.frame = CGRectMake(Screen_width-60-20, topOrigin, 60, 30);
        _countdownBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [_countdownBtn setTitleColor:[UIColor whiteColor] forState:0];
        _countdownBtn.layer.cornerRadius = 5.0;
        _countdownBtn.layer.masksToBounds = YES;
        [_countdownBtn setTitle:@"跳过5" forState:0];
        _countdownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_countdownBtn addTarget:self action:@selector(hiddenSkipBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countdownBtn;
}

#pragma mark - configMethod
- (void)configWebView:(NSString *)webUrl {
    
    [self.webView loadRequestWithString:webUrl];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    
    [self.view addSubview:self.topView]; // 设置顶部视图
}

- (void)configBgView {
    self.bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height)];
    self.bgImgView.userInteractionEnabled = YES;
    
    NSString *key = [NSString stringWithFormat:@"%dx%d", (int)Screen_width, (int)Screen_height];
    if (IS_SCREEN_61_INCH && [key isEqualToString:@"414x896"]) {
        // 为iPhoneXR
        self.bgImgView.image = [UIImage imageNamed:@"LaunchImage-1200-Portrait-1792h"];
    }else {
        self.bgImgView.image = [UIImage imageNamed:[Utility lanchImageInch:key]];
    }
    
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.countdownBtn];
    
    [self addTimer]; // 添加计时器
}

// 添加计时器
- (void)addTimer {
    __weak typeof(self)wealSelf = self;
    // 跳过计时器
    self.timerJump = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES limitCount:5 countdownCallback:^(NSUInteger countdown){
        [wealSelf.countdownBtn setTitle:[NSString stringWithFormat:@"跳过%ld",5-(long)countdown] forState:0];
    }timerEndCallback:^{
        [wealSelf hiddenSkipBtn];
    }];

    // 超时计时器
    self.timeOut = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES limitCount:8 countdownCallback:^(NSUInteger countdown){} timerEndCallback:^{
        // 当超时时间到时，显示重新加载页面
        // 加载后会执行 didFinishNavigation 代理方法
        Utility *utility = [[Utility alloc] init];
        [utility onTimeOutAction:wealSelf.webView];
    }];
}

// 隐藏跳过按钮
- (void)hiddenSkipBtn {
    [self.timerJump invalidate];
    self.timerJump = nil;
    
    self.countdownBtn.hidden = YES;
    
    if (self.isFirstLoad)
    {// 加载结束
        [self removeBgImageView];
    }
}

// 移除背景图
- (void)removeBgImageView {
    [self.timeOut invalidate];
    self.timeOut = nil;
    [self loadFinishAnimation]; // 加载结束动画以及检测版本更新
}

// 加载结束动画以及检测版本更新
- (void)loadFinishAnimation {
    // 蒙版做动画操作
    [UIView animateWithDuration:1.0 animations:^{
        self.bgImgView.alpha = 0;
    } completion:^(BOOL finished){
        [self.bgImgView removeFromSuperview];
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self checkAppVersion]; // 检测app版本更新
    });
}

#pragma mark - 检测app版本更新
- (void)checkAppVersion {
    __weak typeof(self)weakSelf = self;
    [UpdateAppVersion hs_updateWithAPPID:APP_ID block:^(NSString *currentVersion, NSString *storeVersion, NSString *openUrl, BOOL isUpdate) {
        if (isUpdate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showStoreVersion:storeVersion openUrl:openUrl];
            });
        }
    }];
}

- (void)showStoreVersion:(NSString *)storeVersion openUrl:(NSString *)openUrl {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发现新版本" message:[NSString stringWithFormat:@"修复细节问题，优化交互体验，马上更新体验吧！"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIHelper openUrl:[NSURL URLWithString:openUrl] showOpenFailTip:NO];
    }];
    [actionYes setValue:[UIColor redColor] forKey:@"_titleTextColor"]; // 设置字体颜色
    [alertController addAction:actionYes];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 * webView加载完毕后执行
 */
- (void)webviewDidFinishLoad {
    if (!self.timerJump && !self.isFirstLoad)
    {// 移除背景视图
        [self removeBgImageView];
    }
    
    if (self.isCheckVersion) {
        [self removeBgImageView];
        self.isCheckVersion = NO;
    }
    
    if ([self.webView.URL.scheme containsString:@"file"])
    {// 当在弱网或者无网时，需要重新检查版本
        self.isCheckVersion = YES;
    }
    
    if (!self.isFirstLoad)
    {// 首次加载
        self.isFirstLoad = YES;
    }
    
    [self setWebViewHeaderView]; // 设置webview顶部返回视图
}

// 设置webView顶部返回视图（部分页面可能无法返回）
- (void)setWebViewHeaderView {
    NSString *scheme = [NSURL URLWithString:self.hostName].scheme;
    if ([self.hostName containsString:@"tscenter.alipay.com"] ||
        [self.hostName containsString:@"mclient.alipay.com"]  ||
        [scheme containsString:@"alipay"]) {
        self.topView.hidden   = NO;
        self.isDispalyTopView = YES;
        self.webView.frame = CGRectMake(0, TopBarSafeHeight+self.topView.frame.size.height, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-TopBarSafeHeight-BottomSafeHeight-self.topView.frame.size.height);
    }else {
        self.topView.hidden = YES;
        if (self.isDispalyTopView) {
            self.webView.frame = CGRectMake(0, TopBarSafeHeight, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-TopBarSafeHeight-BottomSafeHeight);
            self.isDispalyTopView = NO;
        }
    }
}

@end

//
//  WebKitViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/5/23.
//  Copyright © 2019 TW. All rights reserved.
//

#import "WebKitViewController.h"
#import "ACETelPrompt.h"
#import "NSURL+Extension.h"

@interface WebKitViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WebKitViewController

#pragma mark - 初始化
- (id)bridge {
    if (!_bridge) {
        _bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView *)self.webView];
        [_bridge setWebViewDelegate:self];
    }
    return _bridge;
}

- (QqcWebView *)webView {
    if (!_webView) {
        if (iphoneX) {
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 44, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-44-34)];
        }else {
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height)];
        }
        
        if (@available(iOS 11.0, *))
        {//  防止无导航栏时顶部出现44高度的空白 (适配iPhone X)
            ((WKWebView *)_webView).scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        // 设置UserAgent
        NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        [_webView addToWebViewUserAgent:version];
        
        [_webView allowDisplayingKeyboardWithoutUserAction]; // 唤起键盘
    }
    return _webView;
}

#pragma mark - Config
- (void)configWebView {
    
    [self.view insertSubview:self.webView atIndex:0];
//    [self.view addSubview:self.webView];
}

- (void)configProgress {
    // 进度条
    CGFloat topMargin = 0;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, topMargin, Screen_width, 0)];
    progressView.tintColor = [UIColor orangeColor];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.webView addSubview:progressView];
    self.progressView = progressView;
}

#pragma mark - KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"])
    {// 获取网页加载进度
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.progressView.alpha = 1.0f;
        [self.progressView setProgress:newprogress animated:YES];
        if (newprogress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.progressView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0 animated:NO];
                             }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configWebView];
    [self configProgress];
}

#pragma mark - WKWebView Delegate Methods
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *hostname = navigationAction.request.URL.absoluteString;
    self.hostName = hostname;
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated
        && [hostname containsString:@"tel:"]) {
        // 对于跨域，需要手动跳转
        NSString *str = navigationAction.request.URL.absoluteString;
        NSString *telStr = [str substringFromIndex:4];
        
        [ACETelPrompt callPhoneNumber:telStr call:nil cancel:nil];
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else {
        NSString *urlString = [hostname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // 调起微信支付时，将先前网页地址设置成app的标识，即不会跳回浏览器中
        if ([urlString containsString:@"wx.tenpay.com"])
        {// 判断是否有mweb_url微信支付跳转链接
            NSDictionary *headers = [navigationAction.request allHTTPHeaderFields];
            
            NSString *referer = [headers valueForKey:@"Referer"];
            if ([referer containsString:[NSString stringWithFormat:@"%@://",URL_DOMAIN_NAME]]) {
            } else {
                // relaunch with a modified request
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSURL *url = [navigationAction.request URL];
                        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                        //设置Referer为app的标识(即来路地址)
                        [request setHTTPMethod:@"GET"];
                        [request setValue:[NSString stringWithFormat:@"%@://",URL_DOMAIN_NAME] forHTTPHeaderField:@"Referer"];
                        [(WKWebView*)(self.webView) loadRequest:request];
                    });
                });
            }
        }
        
        if (![urlString hasPrefix:@"http"]) { // 不包含http或https协议，为其他协议
            NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
            NSArray *schemes = [bundleDic objectForKey:@"LSApplicationQueriesSchemes"];
            
            NSString *scheme = navigationAction.request.URL.scheme; // 获取当前链接协议
            if ([schemes containsObject:scheme])
            {// 判断当前链接协议是否在设置的白名单中
                [self openUrl:navigationAction.request.URL showOpenFailTip:YES];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
        else if([urlString containsString:@"itunes.apple.com"]) { // 跳转到App Store
            [self openUrl:navigationAction.request.URL showOpenFailTip:NO];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation");
    [self webviewDidFinishLoad];
}

//开始加载数据时失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation");
    Utility *utility = [[Utility alloc] init];
    [utility catchError:error webView:webView];
}

//当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    Utility *utility = [[Utility alloc] init];
    [utility catchError:error webView:webView];
}

// 处理当内存过大时，webview进程被终止，导致内容加载不出，而出现白屏情况
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"进程被终止");
}

#pragma mark - 打开Url
- (void)openUrl:(NSURL *)url
showOpenFailTip:(BOOL)showOpenFailTip {
    // 打开url链接，设置是否显示未装提示
    [url openUrlWithIsShowFailTip:showOpenFailTip];
}

/**
  * webview加载完毕后执行
 */
- (void)webviewDidFinishLoad {}

@end

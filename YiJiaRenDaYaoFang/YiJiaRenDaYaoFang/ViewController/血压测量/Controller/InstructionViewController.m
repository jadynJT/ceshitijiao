//
//  InstructionViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/7/18.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "InstructionViewController.h"

@interface InstructionViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, strong) QqcWebView* webView;
@property (nonatomic, strong) id bridge;

@end

@implementation InstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGBA(0xf5f5f5, 1.0);
    
    NSString *url = URL_INSTRUCTION;
    [self.webView loadRequestWithString:url];
    [self.view addSubview:self.webView];
    
    [self regJSApi];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (QqcWebView *)webView
{
    if (!_webView) {
        if (iphoneX) {
            _webView = (QqcWebView*)[[WKWebView alloc] initWithFrame:CGRectMake(0, 44, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-44-34)];
        }else {
            _webView = (QqcWebView*)[[WKWebView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height)];
        }
        if (@available(iOS 11.0, *))
        {//  防止无导航栏时顶部出现44高度的空白 (适配iPhone X)
            ((WKWebView *)_webView).scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _webView;
}

- (id)bridge {
    if (!_bridge) {
        _bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)self.webView];
        [_bridge setWebViewDelegate:self];
    }
    return _bridge;
}

#pragma mark - 注册JS接口

- (void)regJSApi {
    __weak typeof(self) weakSelf = self;
    WVJBHandler backRecordHandle = ^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%s 数据记录页面 返回按钮 被触发", __FUNCTION__);
        //调用返回方法
        [weakSelf backBtnClick];
    };
    
    [self.bridge registerHandler:@"backCode" handler:backRecordHandle];
}

- (void)backBtnClick {
    //返回测量页面
    self.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X38393e, 1.0);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WKWebView Delegate Methods

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [SVProgressHUD showWithStatus:@"loading..."];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [SVProgressHUD dismiss];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [SVProgressHUD dismiss];
    if (error.code == -999) {
        return;
    }
    
    if (error.code == -1009 || error.code == -1005) {
        [SVProgressHUD showInfoWithStatus:@"请检查您的网络状态"];
    }else if (error.code == -1001) {
        [webView loadRequestWithString:URL_INSTRUCTION];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [SVProgressHUD dismiss];
    
    if (error.code == -999) {
        return;
    }
    
    if (error.code == -1009 || error.code == -1005) {
        [SVProgressHUD showInfoWithStatus:@"请检查您的网络状态"];
    }else if (error.code == -1001){
        [webView loadRequestWithString:URL_INSTRUCTION];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

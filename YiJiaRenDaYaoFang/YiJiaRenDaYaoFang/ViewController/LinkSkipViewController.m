//
//  LinkSkipViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2018/7/21.
//  Copyright © 2018年 TW. All rights reserved.
//

#import "LinkSkipViewController.h"

@interface LinkSkipViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (strong, nonatomic) QqcWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation LinkSkipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom; // 从navigationBar下面开始计算
    
    // webview
    CGFloat topmargin = 44;
    if (iphoneX) {// 有齐刘海
        topmargin = 88;
    }
    
    self.webView = (QqcWebView*)[[WKWebView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-topmargin)];
    ((WKWebView *)self.webView).UIDelegate = self;
    ((WKWebView *)self.webView).navigationDelegate = self;
    [self.webView loadRequestWithString:self.result];
    [self.view addSubview:self.webView];
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_width, 0)];
    progressView.tintColor = [UIColor orangeColor];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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

    else if ([keyPath isEqualToString:@"title"])
    {// 获取网页标题
        if (object == self.webView) {
            self.title = ((WKWebView *)self.webView).title;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
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

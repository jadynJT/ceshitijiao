//
//  QqcWebViewAdapter.h
//  QqcWebViewAdapter
//
//  Created by qiuqinchuan on 15/9/21.
//  Copyright (c) 2015年 ZQ. All rights reserved.
//

/**
 *  WKWebView的坑：
 *  1.无法加载本地的html
 *
 */

#ifndef QqcWebViewAdapter_QqcWebViewAdapter_h
#define QqcWebViewAdapter_QqcWebViewAdapter_h

#define QqcWebView UIView<QqcWebViewAdapter>

/**
 *  WKWebView 的设配接口
 */
@protocol QqcWebViewAdapter <NSObject>

#pragma mark - 属性

/**
 *  WKWebView 中有此属性
 */
@property (nonatomic, strong, readonly) NSURL *URL;


#pragma mark - 方法

/**
 *  WKWebView 有不同的设置delegate的接口，这里做统一
 *  WKWebView 代理是 id <WKNavigationDelegate> navigationDelegate 和 id <WKUIDelegate> UIDelegate
 *  @param delegate id <WKNavigationDelegate,WKUIDelegate>
 */
- (void)setDelegateVC:(id)delegate;

/**
 * 回退到上一个页面
 */
- (void)setGoBack;


/**
 * 重新刷新
 */
- (void)setReLoad;

/*
 * WKWebView 使用 evaluateJavaScript
 * 提供统一的接口
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *)) completionHandler;

/**
 *  通过字符串 url 加载
 *
 *  @param strUrl url字符串
 */
- (void)loadRequestWithString:(NSString *)strUrl;

/**
 *  设置UserAgent
 *
 */
- (void)addToWebViewUserAgent:(NSString *)addAgent;

/**
 *  显示键盘（iOS12之前使用）
 *
 */
//- (void)wkWebViewShowKeybord;

/**
 * web页面唤起键盘（iOS12使用）
 *
*/
- (void)allowDisplayingKeyboardWithoutUserAction;

/**
 *  wwebView长屏幕截取
 *
 */
- (void)contentCaptureCompletionHandler:(void(^)(UIImage *capturedImage))completionHandler;

@end

#endif

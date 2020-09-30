//
//  TWWebViewComponent.h
//  yss
//
//  Created by admin on 16/4/16.
//  Copyright © 2016年 JZTW. All rights reserved.
//

#ifndef TWWebViewComponent_h
#define TWWebViewComponent_h

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "WKWebView+adapter.h"
#import "WebViewJavascriptBridgeBase.h"
#import "WKWebViewJavascriptBridge.h"

#import "QqcWebViewAdapter.h"
#import "QRCodeReaderViewController.h"

#define QqcWebViewJavascriptBridge id<WebViewJavascriptBridgeBaseDelegate>
#define QqcWebView UIView<QqcWebViewAdapter>

#endif /* TWWebViewComponent_h */

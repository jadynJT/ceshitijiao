//
//  WebKitViewController.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2019/5/23.
//  Copyright © 2019 TW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebKitViewController : UIViewController

@property (nonatomic, strong) id bridge;
@property (nonatomic, strong) QqcWebView *webView;
@property (nonatomic,   copy) NSString *hostName; // URL地址

/**
  * webview加载完毕后执行
 */
- (void)webviewDidFinishLoad;

@end

NS_ASSUME_NONNULL_END

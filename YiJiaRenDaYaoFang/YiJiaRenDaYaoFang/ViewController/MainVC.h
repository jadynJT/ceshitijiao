//
//  MainVC.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/1/20.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderViewController.h"
#import "WebViewJSBridgeViewController.h"
#import "WXApi.h"

typedef enum : NSInteger {
    locationFail    = -1,
    locationSuccess = 0
} locationState;

@interface MainVC : WebViewJSBridgeViewController

- (void)configWebView:(NSString *)webUrl;

- (void)showStoreVersion:(NSString *)storeVersion openUrl:(NSString *)openUrl;

@end

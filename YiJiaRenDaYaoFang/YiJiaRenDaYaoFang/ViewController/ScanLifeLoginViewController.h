//
//  ScanLifeRegisterViewController.h
//  YiJiaRenDaYaoFang
//
//  Created by JS1-ZJT on 16/9/23.
//  Copyright © 2016年 Nenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanLifeLoginViewController : UIViewController

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UILabel *loginComfirmLabel;
@property (nonatomic, strong) UIImageView *loginComfirmImageView;

@property (nonatomic, strong) NSString *scanLifeValue; //二维码字段

@property (nonatomic, copy)void(^viewWillDismiss)();  // 视图将要消失
@property (nonatomic, copy)void(^loginBlock)();       // 登录
@property (nonatomic, copy)void(^reScanningBlock)();  // 重新扫描
@property (nonatomic, copy)void(^cancelLoginBlock)(); // 取消登录

@end

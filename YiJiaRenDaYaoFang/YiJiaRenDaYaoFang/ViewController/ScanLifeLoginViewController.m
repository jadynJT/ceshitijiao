//
//  ScanLifeRegisterViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by JS1-ZJT on 16/9/23.
//  Copyright © 2016年 Nenglong. All rights reserved.
//

#import "ScanLifeLoginViewController.h"
#import "SVProgressHUD.h"
#import "SDAutoLayout.h"

#define kScaleByView    [UIScreen mainScreen].bounds.size.width/320.0f

@interface ScanLifeLoginViewController()

@end

@implementation ScanLifeLoginViewController

-(UIImageView *)loginComfirmImageView {
    if (!_loginComfirmImageView) {
        self.loginComfirmImageView = [[UIImageView alloc] init];
        [self.view addSubview:self.loginComfirmImageView];
    }
    return _loginComfirmImageView;
}

-(UILabel *)loginComfirmLabel {
    if (!_loginComfirmLabel) {
        self.loginComfirmLabel = [[UILabel alloc] init];
        [self.view addSubview:self.loginComfirmLabel];
        self.loginComfirmLabel.text = @"电脑端登录确认";
        self.loginComfirmLabel.font = [UIFont systemFontOfSize:16];
        self.loginComfirmLabel.textColor = [UIColor blackColor];
        self.loginComfirmLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _loginComfirmLabel;
}

-(UILabel *)tipLabel {
    if (!_tipLabel) {
        self.tipLabel = [[UILabel alloc] init];
        [self.view addSubview:self.tipLabel];
        self.tipLabel.font = [UIFont systemFontOfSize:16];
        self.tipLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
        self.loginComfirmLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

-(UIButton *)loginBtn {
    if (!_loginBtn) {
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:self.loginBtn];
        [self.loginBtn setTitle:@"确认登录电脑端" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        self.loginBtn.enabled = YES;
        [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.loginBtn setBackgroundColor:[UIColor colorWithRed:46/255.0 green:153/255.0 blue:235/255.0 alpha:1]];
        [self.loginBtn addTarget:self action:@selector(loginSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.loginBtn addTarget:self action:@selector(loginDownSelect:) forControlEvents:UIControlEventTouchDown];
    }
    return _loginBtn;
}

-(UIButton *)cancelBtn {
    if (!_cancelBtn) {
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelBtn setTitle:@"取消登录" forState:UIControlStateNormal];
        [self.view addSubview:self.cancelBtn];
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]  forState:UIControlStateHighlighted];
        [self.cancelBtn setBackgroundColor:[UIColor whiteColor]];
        [self.cancelBtn addTarget:self action:@selector(cancelSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.00f];
    self.title = @"扫码登录";

    [self sdLayout];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewWillDismiss ? self.viewWillDismiss() : nil;
}

-(void)sdLayout {
    CGFloat margin = 25;
    
    //图片宽高比例
    UIImage *currentImage = [UIImage imageNamed:@"ewm"];
    CGFloat Btn_H = 100*kScaleByView;
    CGFloat img_scale = currentImage.size.width/currentImage.size.height;
    CGFloat Btn_W = Btn_H*img_scale;//图片宽
    self.loginComfirmImageView.sd_layout
    .centerXEqualToView(self.view)
    .topSpaceToView(self.view, 120)
    .widthIs(Btn_W)
    .heightIs(Btn_H);
    self.loginComfirmImageView.image = currentImage;
    
    self.loginComfirmLabel.sd_layout
    .centerXEqualToView(self.loginComfirmImageView)
    .topSpaceToView(self.loginComfirmImageView, margin)
    .leftSpaceToView(self.view, margin-5)
    .rightSpaceToView(self.view, margin-5)
    .heightIs(20);
    [_loginComfirmLabel.superview layoutIfNeeded];
    
    self.tipLabel.sd_layout
    .centerXEqualToView(self.loginComfirmImageView)
    .topSpaceToView(self.loginComfirmLabel, margin-10)
    .heightIs(20);
    [_tipLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    self.cancelBtn.sd_layout
    .centerXEqualToView(self.loginComfirmImageView)
    .bottomSpaceToView(self.view, 80*kScaleByView)
    .leftSpaceToView(self.view, margin-5)
    .rightSpaceToView(self.view, margin-5)
    .heightIs(_cancelBtn.intrinsicContentSize.height+10);
    
    self.loginBtn.sd_layout
    .centerXEqualToView(self.loginComfirmImageView)
    .bottomSpaceToView(self.cancelBtn, 20*kScaleByView)
    .leftSpaceToView(self.view, margin-5)
    .rightSpaceToView(self.view, margin-5)
    .heightIs(_loginBtn.intrinsicContentSize.height+10);
}

#pragma mark - Actions
-(void)loginDownSelect:(UIButton *)sender {
    self.loginBtn.layer.borderColor = [UIColor colorWithRed:128/255.0 green:221/255.0 blue:126/255.0 alpha:0.6].CGColor;
}

//**确认按钮事件**//
-(void)loginSelect:(UIButton *)sender {
    if ([sender.currentTitle containsString:@"登录"]) {
        self.loginBlock(); // 登录回调
    }else{
        [self.loginBtn setBackgroundColor:[UIColor redColor]];
        self.reScanningBlock(); // 重新扫描回调
    }
}

//**取消按钮事件**//
-(void)cancelSelect:(UIButton *)sender {
    self.cancelLoginBlock(); // 取消登录回调
}

//**关闭按钮事件**//
-(void)closeSelect:(UIButton *)sender {
    [(UINavigationController *)self.presentingViewController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 禁止横屏
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {}

@end

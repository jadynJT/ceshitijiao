//
//  MeasurePageViewController.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/6/14.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "MeasurePageViewController.h"
#import "RecordViewController.h"
#import "InstructionViewController.h"
#import "BloodPressModel.h"
#import "ManualInputView.h"
#import "MeasureView.h"
#import "BloodGlucose.h"
#import "MFPickerView.h"
#import "CustomSegControl.h"
#import "AFSecurityPolicy.h"
#import "AFHTTPSessionManager.h"
#import "GlucoseViewController.h"
#import "ViewCroViewController.h"

@interface MeasurePageViewController ()<WKNavigationDelegate,WKUIDelegate,NSURLSessionDelegate,UITextFieldDelegate,ManualInputViewDelegate,MeasureViewDelegate,BloodGlucoseDelegate,UIGestureRecognizerDelegate>{
}

@property (strong, nonatomic) UISegmentedControl *bloodPressureSeg;
@property (strong, nonatomic) UISegmentedControl *bloodGlucoseSeg;

@property (nonatomic, strong) QqcWebView* webView;
@property (nonatomic, strong) id bridge;
@property (nonatomic, strong) ViewCroViewController *viewCro;
@property (nonatomic, strong) GlucoseViewController *glucoseVC;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) ManualInputView *manualView;
@property (nonatomic, strong) MeasureView *measureView;
@property (nonatomic, strong) BloodGlucose *bloodGlucose;
@property (nonatomic, strong) UILabel *bottomLab;

@property (nonatomic, assign) BOOL bIsBluetoothOn;
@property (nonatomic, assign) BOOL isFeatured;

@end

@implementation MeasurePageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 从navigationBar下面开始计算
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    //蓝牙接口调用
    [self measureTask];

    [self configNavBar];
    [self.view addSubview:self.bottomLab];
    WeakSelf(weakSelf);
    [_bottomLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-BottomSafeHeight);
        make.left.equalTo(weakSelf.view).offset(0);
        make.height.mas_equalTo(40);
        make.right.equalTo(weakSelf.view).offset(0);
    }];
    [_bottomLab layoutIfNeeded];

    [self regJSApi];
    //添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.delegate = self;

    [self.view addGestureRecognizer:singleTap];

    self.measureView.circleView.haveFinished = 0.75;
}

#pragma mark - 初始化

- (UILabel *)bottomLab{
    if (!_bottomLab) {
        _bottomLab = [UILabel new];
        _bottomLab.font = [UIFont boldSystemFontOfSize:12.0];
        _bottomLab.text = @"  如您还没有血压计，可联系药店购买，测量更便捷、准确。";
        _bottomLab.textColor = UIColorFromRGBA(0xFFFFFF, 0.8);
        [_bottomLab setBackgroundColor:UIColorFromRGBA(0x7A7A7A, 0.9)];
    }
    return _bottomLab;
}

- (UISegmentedControl *)bloodPressureSeg{
    if (!_bloodPressureSeg) {
        
        CGFloat topOrigin = 44;
        if (IsiPhoneX) {
            topOrigin = 88;
        }
        
        _bloodPressureSeg = [[UISegmentedControl alloc]initWithItems:@[@"血压计测量",@"手动输入"]];
        _bloodPressureSeg.frame = CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, 44);
        [_bloodPressureSeg setTintColor:[UIColor whiteColor]];
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
                                                   NSForegroundColorAttributeName: UIColorFromRGBA(0x47B6EF, 0.8)};
        [_bloodPressureSeg setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        [_bloodPressureSeg setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateSelected];
        _bloodPressureSeg.selectedSegmentIndex = 0;
        _bloodPressureSeg.tag = 310;
        [_bloodPressureSeg addTarget:self action:@selector(SegmentControlChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _bloodPressureSeg;
}

- (UISegmentedControl *)bloodGlucoseSeg{
    if (!_bloodGlucoseSeg) {
        
        CGFloat topOrigin = 44;
        if (IsiPhoneX) {
            topOrigin = 88;
        }
        
        _bloodGlucoseSeg = [[UISegmentedControl alloc] initWithItems:@[@"血糖仪测量",@"手动输入"]];
        _bloodGlucoseSeg.frame = CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, 44);
        [_bloodGlucoseSeg setTintColor:[UIColor whiteColor]];
        
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
                                                   NSForegroundColorAttributeName: UIColorFromRGBA(0xde4444, 0.8)};
        [_bloodGlucoseSeg setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        [_bloodGlucoseSeg setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateSelected];
        _bloodGlucoseSeg.selectedSegmentIndex = 0;
        _bloodGlucoseSeg.tag = 311;
        [_bloodGlucoseSeg addTarget:self action:@selector(SegmentControlChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _bloodGlucoseSeg;
}

- (ManualInputView *)manualView{
    if (!_manualView) {
        
        CGFloat topOrigin = 44;
        if (IsiPhoneX) {
            topOrigin = 88;
        }
        
        _manualView = [[ManualInputView alloc] initWithFrame:CGRectMake(0, 44, UISCREEN_BOUNCES.size.width, (58*4+54*2+34)/736.0*UISCREEN_BOUNCES.size.height)];
        _manualView.delegate = self;
    }
    return _manualView;
}

- (MeasureView *)measureView {
    if (!_measureView) {
        
        CGFloat topOrigin = 44;
        if (IsiPhoneX) {
            topOrigin = 88;
        }
        
        _measureView = [[MeasureView alloc] initWithFrame:CGRectMake(0, 44, UISCREEN_BOUNCES.size.width, 44+44+(440-44)/Proportion_height)];
        _measureView.delegate = self;
    }
    return _measureView;
}

- (BloodGlucose *)bloodGlucose {
    if (!_bloodGlucose) {
        
        CGFloat topOrigin = 44;
        if (IsiPhoneX) {
            topOrigin = 88;
        }
        
        _bloodGlucose = [[BloodGlucose alloc] initWithFrame:CGRectMake(0, 44, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height - 44*3)];
        _bloodGlucose.delegate = self;
    }
    return _bloodGlucose;
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

- (id)bridge
{
    if (!_bridge) {
        _bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)self.webView];
        [_bridge setWebViewDelegate:self];
    }
    
    return _bridge;
}

// 跳转网页
- (ViewCroViewController *)viewCro{
    if (!_viewCro) {
        _viewCro = [[ViewCroViewController alloc]init];
        _viewCro.view.backgroundColor = UIColorFromRGBA(0xf5f5f5, 1.0);
    }
    return _viewCro;
}

- (GlucoseViewController *)glucoseVC{
    if (!_glucoseVC) {
        _glucoseVC = [[GlucoseViewController alloc]init];
        _glucoseVC.view.backgroundColor = UIColorFromRGBA(0xf5f5f5, 1.0);
    }
    return _glucoseVC;
}

#pragma mark - 注册JS接口
- (void)regJSApi {
    WeakSelf(weakSelf);
    WVJBHandler backRecordHandle = ^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%s 数据记录页面 返回按钮 被触发", __FUNCTION__);
        //调用返回方法
        [weakSelf backBtnClick];
    };
    
    [self.bridge registerHandler:@"backCode" handler:backRecordHandle];
    
//    if ([self.bridge isKindOfClass:[WebViewJavascriptBridge class]])
//    {
//        [(WebViewJavascriptBridge*)self.bridge registerHandler:@"backCode" handler:backRecordHandle];
//    }else if ([self.bridge isKindOfClass:[WKWebViewJavascriptBridge class]]){
//        [(WKWebViewJavascriptBridge*)self.bridge registerHandler:@"backCode" handler:backRecordHandle];
//    }
}

- (void)doSearchForJS {
    [self.bridge callHandler:@"searchForJS"];
    
//    if ([self.bridge isKindOfClass:[WebViewJavascriptBridge class]])
//    {
//        [(WebViewJavascriptBridge*)self.bridge callHandler:@"searchForJS"];
//    }else if ([self.bridge isKindOfClass:[WKWebViewJavascriptBridge class]]){
//        [(WKWebViewJavascriptBridge*)self.bridge callHandler:@"searchForJS"];
//    }
}

#pragma mark - UI布局
- (void)measureTask{
    __weak typeof(self)weakSelf = self;
    if ([TJBluetoothEngine shareTJBluetoothEngine].strConnectState && ![[TJBluetoothEngine shareTJBluetoothEngine].strBattery isEqualToString:@""]) {
        self.measureView.batteryValueLabel.text = [TJBluetoothEngine shareTJBluetoothEngine].strBattery;
    }
    
    if ([TJBluetoothEngine shareTJBluetoothEngine].strBattery && ![[TJBluetoothEngine shareTJBluetoothEngine].strConnectState isEqualToString:@""]) {
        self.measureView.stateLabel.text = [TJBluetoothEngine shareTJBluetoothEngine].strConnectState;
    }
    
    [[TJBluetoothEngine shareTJBluetoothEngine]launchWithBlock:^(NSData *dataConfigCode) {
        
    } autoCheckRet:^(NSData *dataCheckRet) {
        
        Byte * pressureByte = (Byte *)[dataCheckRet bytes];
        if (0xB7 == pressureByte[2]){
            weakSelf.measureView.circleView.haveFinished = 0.8;
            weakSelf.measureView.circleView.countlabel.text = [NSString stringWithFormat:@"%hhu",pressureByte[4]];
        }
        if(0xB5 == pressureByte[2]){
            weakSelf.measureView.batteryValueLabel.text = [NSString stringWithFormat:@"%hhu%@",pressureByte[3],@"%"];
        }
        if (0xB9 == pressureByte[2]){
            //测量错误
            weakSelf.measureView.circleView.countlabel.text = @"0";
            [SVProgressHUD showInfoWithStatus:@"错误，请重新测量"];
        }
    } devPowerOff:^(BOOL bIsPowerOff) {
        if (bIsPowerOff) {
            weakSelf.measureView.circleView.countlabel.text = @"0";
        }
        
    } autoCheckRetResult:^(NSData *dataCheckRetResult) {
        if (!(nil == dataCheckRetResult)) {
            [weakSelf requestForMeasureResult:dataCheckRetResult];
        }
        
    } connectState:^(NSString *connectState) {
        weakSelf.measureView.stateLabel.text = connectState;
    }];
}

- (void)configNavBar {
    WeakSelf(weakSelf);
    
    CustomSegControl *segment = [[CustomSegControl alloc]initWithItemTitles:@[@"血压测量",@"血糖测量"]];
    
    self.navigationItem.titleView = segment;
    segment.frame = CGRectMake(0, 0, 160, 30);
    [segment clickDefault];
    self.isFeatured = YES;

    [self.view addSubview:self.bloodPressureSeg];
    self.view.backgroundColor = UIColorFromRGBA(0xf5f5f5, 1.0);
    [self.view addSubview:self.measureView];
  
    
    segment.CustomSegmentViewBtnClickHandle = ^(CustomSegControl *segment, NSString *title,NSInteger currentIndex){
        weakSelf.isFeatured = (currentIndex == 0);
        weakSelf.manualView.hidden = !weakSelf.isFeatured;
        weakSelf.bloodGlucose.hidden = weakSelf.isFeatured;
        weakSelf.bloodPressureSeg.hidden = !weakSelf.isFeatured;
        weakSelf.bloodGlucoseSeg.hidden = weakSelf.isFeatured;
        
        switch (currentIndex) {
            case 0:{
                if (weakSelf.manualView) {
                    [weakSelf.manualView removeFromSuperview];
                }

                [weakSelf.view addSubview:weakSelf.bloodPressureSeg];
                weakSelf.bloodPressureSeg.selectedSegmentIndex = 0;
                //显示血压测量页面
                [weakSelf.view addSubview:weakSelf.measureView];
                weakSelf.measureView.BMPPowerLabel.text = @"血压计电量";
                [weakSelf.measureView.batteryImgView setImage:[UIImage imageNamed:@"icon_battery"]];
                [weakSelf.measureView.blueToothImgView setImage:[UIImage imageNamed:@"icon_bluetooth"]];
                [weakSelf.measureView.bgImgView setImage:[UIImage imageNamed:@"top_background"]];
                [weakSelf.measureView.startBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
                weakSelf.measureView.instructionBtn.hidden = NO;
                weakSelf.bottomLab.text = @"  如您还没有血压计，可联系药店购买，测量更便捷、准确。";
                weakSelf.measureView.circleView.unitLabel.text = @"mmHg";
            }
                break;
                
            case 1:{
                if (weakSelf.bloodGlucose) {
                    [weakSelf.bloodGlucose removeFromSuperview];
                }
//                weakSelf.measureView.circleView.unitLabel.text= @"";
                //显示血糖测量页面
                [weakSelf.view addSubview:weakSelf.bloodGlucoseSeg];
                weakSelf.bloodGlucoseSeg.selectedSegmentIndex = 0;
                [weakSelf.view addSubview:weakSelf.measureView];
                weakSelf.measureView.BMPPowerLabel.text = @"血糖仪电量";
                [weakSelf.measureView.batteryImgView setImage:[UIImage imageNamed:@"icon_battery_glucose"]];
                [weakSelf.measureView.blueToothImgView setImage:[UIImage imageNamed:@"icon_bluetooth_glucose"]];
                [weakSelf.measureView.bgImgView setImage:[UIImage imageNamed:@"top_glucose_bg"]];
                [weakSelf.measureView.startBtn setBackgroundImage:[UIImage imageNamed:@"button_glucose"] forState:UIControlStateNormal];
                weakSelf.measureView.instructionBtn.hidden = YES;
                weakSelf.bottomLab.text = @"  如您还没有血糖仪，可联系药店购买，测量更便捷、准确。";
                weakSelf.measureView.circleView.unitLabel.text = @"mmol/L";
            }
                break;
                
            default:
                break;
        }
    };
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"记录" style:UIBarButtonItemStyleBordered target:self action:@selector(onRecordAction)];
    
    [self.navigationItem setRightBarButtonItem:rightBtn];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X333333, 1.0);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)SegmentControlChange:(UISegmentedControl *)sender
{
    if (sender.tag == 310) {
        if (sender.selectedSegmentIndex == 0) {
            NSLog(@"显示 血压计测量 页面");
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            attDic[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
            attDic[NSForegroundColorAttributeName] = UIColorFromRGBA(0x646464, 0.8);
            [_bloodPressureSeg setTitleTextAttributes:attDic forState:UIControlStateNormal];
            
            [self.view addSubview:self.measureView];
            [self.manualView removeFromSuperview];
            [self.bloodGlucose removeFromSuperview];
        }else{
            NSLog(@"显示 手动输入 页面");
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            attDic[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
            attDic[NSForegroundColorAttributeName] = UIColorFromRGBA(0x646464, 0.8);
            //attDic[NSForegroundColorAttributeName] = UIColorFromRGBA(0x666, 1.0);
            [_bloodGlucoseSeg setTitleTextAttributes:attDic forState :UIControlStateNormal];
            
            [self.view addSubview:self.manualView];
            [self.measureView removeFromSuperview];
            [self.bloodGlucose removeFromSuperview];
        }
    }
    
    if (sender.tag == 311) {
        if (sender.selectedSegmentIndex == 0) {
            NSLog(@"显示 血糖仪测量 页面");
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            attDic[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
            attDic[NSForegroundColorAttributeName] = UIColorFromRGBA(0x646464, 0.8);
            [_bloodGlucoseSeg setTitleTextAttributes:attDic forState:UIControlStateNormal];
            
            [self.view addSubview:self.measureView];
            [self.manualView removeFromSuperview];
            [self.bloodGlucose removeFromSuperview];
        } else if(sender.selectedSegmentIndex == 1){
            
            NSLog(@"显示 血糖手动输入 页面");
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            attDic[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
            attDic[NSForegroundColorAttributeName] = UIColorFromRGBA(0x646464, 0.8);
            [_bloodGlucoseSeg setTitleTextAttributes:attDic forState:UIControlStateNormal];
         
            [self.view addSubview:self.bloodGlucose];
            [self.measureView removeFromSuperview];
            [self.manualView removeFromSuperview];
        }
    }
}

#pragma mark - request
// 记录页面
- (void)requestForRecordPage{
    NSString *member_id;
    if ([Utility isBlankString:_member_id]) {
        member_id = @"";
    }else{
        member_id = _member_id;
    }
    
    [PPNetworkHelper GET:URL_RECORD parameters:@{@"member_id":member_id} success:^(id responseObject) {
    } failure:^(NSError *error) {}];

}

// 开始测量
- (void)requestForMeasureResult:(NSData *)data{
    WeakSelf(weakSelf);
    BloodPressModel *model = [[BloodPressModel alloc]init];
    Byte * resultByte = (Byte *)[data bytes];
    
    if (0xB8 == resultByte[2]) {
        
        model.high_pressure = [NSString stringWithFormat:@"%hhu",resultByte[4]];
        model.low_pressure = [NSString stringWithFormat:@"%hhu",resultByte[5]];
        model.heart_rate = [NSString stringWithFormat:@"%hhu",resultByte[6]];
        self.measureView.dateStr = [NSString stringWithFormat:@"%hhu-%hhu-%hhu",resultByte[11],resultByte[12],resultByte[13]];
        model.heartrate_range = [NSString stringWithFormat:@"%hhu",resultByte[3]];
    }
    
    if (!_member_id) {
        model.member_id = @"";
    }else{
        model.member_id = _member_id;
    }
    
    NSDictionary *dic = @{@"high_pressure":model.high_pressure,
                          @"low_pressure":model.low_pressure,
                          @"heart_rate":model.heart_rate,
                          @"member_id":model.member_id,
                          @"heartrate_range":model.heartrate_range
                          };
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:URL_MEASURE_RESULT parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"dictionary===%@",responseObject);
        
        [weakSelf.webView loadRequestWithString:URL_MEASURE_RESULT];
        [weakSelf.viewCro.view addSubview:_webView];
        
        if (_viewCro) {
            [weakSelf.navigationController pushViewController:_viewCro animated:YES];
            [weakSelf.navigationController setNavigationBarHidden:YES];
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@",error);
    }];
    
}


#pragma mark - btnAction
- (void)onInstructionAction:(UIButton *)sender{
    //跳转到测量说明页面
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:[InstructionViewController new] animated:YES];
}

- (void)onRecordAction{
    // 跳转到 测量记录 页面
    NSString *url = @"";
    if (_isFeatured) {
        [self requestForRecordPage];
        
        [self.navigationController pushViewController:[RecordViewController new] animated:YES];
        [self.navigationController setNavigationBarHidden:YES];
    }else{
        if ([Utility isBlankString:_member_id]) {
            _member_id = @"";
            url = URL_GLUCOSE_RECORD;
            
        }else{
            url = [NSString stringWithFormat:@"%@?member_id=%@",URL_GLUCOSE_RECORD, _member_id];
        }
        
        [self.webView loadRequestWithString:url];
        [self.glucoseVC.view addSubview:_webView];
        [self.navigationController pushViewController:_glucoseVC animated:YES];
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)onStartBtnAction:(UIButton *)sender{
    //开始测量
    WeakSelf(weakSelf);
    if (!_isFeatured) {
        [SVProgressHUD showInfoWithStatus:@"程序猿正在拼命开发中，敬请期待！"];
        return;
    }
    
    self.measureView.circleView.countlabel.text = @"0";
    [[TJBluetoothEngine shareTJBluetoothEngine]checkWithRet:^(NSData *dataCheckRet) {
        Byte * pressureByte = (Byte *)[dataCheckRet bytes];
        
        if (0xB7 == pressureByte[2]){
            weakSelf.measureView.circleView.haveFinished = 0.8;
            weakSelf.measureView.circleView.countlabel.text = [NSString stringWithFormat:@"%hhu",pressureByte[4]];
        }
        
        if(0xB5 == pressureByte[2]){
            weakSelf.measureView.batteryValueLabel.text = [NSString stringWithFormat:@"%hhu%@",pressureByte[3],@"%"];
        }
        
        if (0xB9 == pressureByte[2]){
            //测量错误
            weakSelf.measureView.circleView.countlabel.text = @"0";
            [SVProgressHUD showInfoWithStatus:@"错误，请重新测量"];
        }
        
    } checkWithRetResult:^(NSData *dataCheckRetResult) {
        [weakSelf requestForMeasureResult:dataCheckRetResult];
    } connectState:^(NSString *connectState) {
        weakSelf.measureView.stateLabel.text = connectState;
    }];
}


// 保存记录按钮
- (void)saveBtnAction:(UIButton *)sender
{
    WeakSelf(weakSelf);
    if (sender.tag == 301) {
        NSLog(@"_member_id = %@",_member_id);
        NSDictionary *glucoseDic = [[NSDictionary alloc]init];
        if ([Utility isBlankString:_member_id]) {
            glucoseDic = @{
                                         @"blood_glucose_value":[NSNumber numberWithFloat:[self.bloodGlucose.stepperView.showTF.text floatValue]],
                                         @"user_record_dates":[NSNumber numberWithLong:[Utility changeTimeToTimeSp:self.bloodGlucose.measureTime]],
                                         @"between_meals":self.bloodGlucose.measureTimeSlot,
                                         };
        }else{
            glucoseDic = @{
                                         @"blood_glucose_value":[NSNumber numberWithFloat:[self.bloodGlucose.stepperView.showTF.text floatValue]],
                                         @"user_record_dates":[NSNumber numberWithLong:[Utility changeTimeToTimeSp:self.bloodGlucose.measureTime]],
                                         @"between_meals":self.bloodGlucose.measureTimeSlot,
                                         @"member_id":_member_id
                                         };
        }
        
        NSLog(@"glucoseDic:%@",glucoseDic);
        
        [SVProgressHUD showWithStatus:@"loading..."];
//        [WKProgressHUD showInView:self.view withText:@"loading..." animated:YES];
        [PPNetworkHelper POST:URL_BLOODGLUCOSE_MANUAL_SAVE parameters:glucoseDic success:^(id responseObject) {
            [SVProgressHUD dismiss];
//            [WKProgressHUD dismissInView:self.view animated:YES];
            
            if ([[responseObject objectForKey:@"err"] intValue] == 0) {
                
                [SVProgressHUD showSuccessWithStatus:[responseObject objectForKey:@"msg"]];
                
                NSString *url = [NSString stringWithFormat:@"%@?member_id=%@",URL_GLUCOSE_RECORD,[responseObject objectForKey:@"member_id"]];
                [weakSelf.webView loadRequestWithString:url];
                [weakSelf.glucoseVC.view addSubview:_webView];
                [weakSelf.navigationController pushViewController:_glucoseVC animated:YES];
                [weakSelf.navigationController setNavigationBarHidden:YES];
            }else{
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"msg"]];
            }
            
        } failure:^(NSError *error) {
//            [WKProgressHUD dismissInView:self.view animated:YES];
            [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:@"服务器出问题了，请检查数据是否输入"];
            NSLog(@"error %@",error);
            
        }];

        return;
    }
    
    [self.manualView.manualInputView reloadData];
    BloodPressModel *model = [[BloodPressModel alloc]init];
    
    if ([Utility isBlankString:_member_id]) {
        model.member_id = @"";
    }else{
        model.member_id = _member_id;
    }
    
    NSDictionary *dic = @{@"high_pressure":self.manualView.highPressure,
                          @"low_pressure":self.manualView.lowPressure,
                          @"heart_rate":self.manualView.heartRate,
                          @"member_id":model.member_id,
                          @"check_date":self.manualView.checkDate,
                          @"is_manual":@"1"
                          };
    
    [SVProgressHUD showWithStatus:@""];
//    [WKProgressHUD showInView:self.view withText:nil animated:YES];
    
    [PPNetworkHelper POST:URL_MANUAL_SAVE parameters:dic success:^(id responseObject) {
        [SVProgressHUD dismiss];
//        [WKProgressHUD dismissInView:self.view animated:YES];
        
        if ([[responseObject objectForKey:@"status"] intValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            
            NSString *url = URL_MANUAL_PAGE;
            [weakSelf.webView loadRequestWithString:url];
            [weakSelf.viewCro.view addSubview:weakSelf.webView];
            [weakSelf.navigationController pushViewController:weakSelf.viewCro animated:YES];
            [weakSelf.navigationController setNavigationBarHidden:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        }
        
    } failure:^(NSError *error) {
//        [WKProgressHUD dismissInView:self.view animated:YES];
        [SVProgressHUD dismiss];
        [SVProgressHUD showInfoWithStatus:@"服务器出问题了，请检查数据是否输入"];
        NSLog(@"error %@",error);
    }];
}

- (void)backBtnClick{
    //返回测量页面
    if (self.viewCro) {
        self.viewCro.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X38393e, 1.0);
        [self.viewCro.navigationController popViewControllerAnimated:YES];
    }

    if (self.glucoseVC) {
        self.glucoseVC.navigationController.navigationBar.barTintColor = UIColorFromRGBA(0X38393e, 1.0);
        [self.glucoseVC.navigationController popViewControllerAnimated:YES];
    }
}

//键盘下落
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (void)showTimeSlot{
   WeakSelf(weakSelf);
    MFPickerView *pickView = [[MFPickerView alloc] init];
    
    [pickView setDataViewWithItem:self.bloodGlucose.picTitleArr title:nil];
    [pickView showPickView:self.view];
    pickView.block = ^(NSDictionary *selectedStr)
    {
        weakSelf.bloodGlucose.measureTimeSlot = [selectedStr objectForKey:@"selectIndex"];
        
        UILabel *lab = [weakSelf.view viewWithTag:205];
        lab.text = [selectedStr objectForKey:@"selectStr"];
    };
}

#pragma mark - WKWebView Delegate Methods
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    static NSInteger flag = 0;
    if (flag == 0) {
        [self doSearchForJS];
        flag = 1;
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doSearchForJS];
        });
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSString *url = @"";
    if ([Utility isBlankString:_member_id]) {
        _member_id = @"";
        url = URL_GLUCOSE_RECORD;
        
    }else {
        url = [NSString stringWithFormat:@"%@?member_id=%@",URL_GLUCOSE_RECORD, _member_id];
    }

    if (error.code == -999) {
        return;
    }
    
    if (error.code == -1009 || error.code == -1005) {
        [SVProgressHUD showInfoWithStatus:@"请检查您的网络状态"];
    }else if (error.code == -1001){
        
        [webView loadRequestWithString:url];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSString *url = @"";
    if ([Utility isBlankString:_member_id]) {
        _member_id = @"";
        url = URL_GLUCOSE_RECORD;
    }else{
        url = [NSString stringWithFormat:@"%@?member_id=%@",URL_GLUCOSE_RECORD, _member_id];
    }
    
    if (error.code == -999) {
        return;
    }
    
    if (error.code == -1009 || error.code == -1005) {
        [SVProgressHUD showInfoWithStatus:@"请检查您的网络状态"];
    }else if (error.code == -1001){
        [webView loadRequestWithString:url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {}

@end

/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderViewController.h"
#import "QRCameraSwitchButton.h"
#import "QRCodeReaderView.h"

@interface QRCodeReaderViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) QRCameraSwitchButton *switchCameraButton;
@property (strong, nonatomic) QRCodeReaderView     *cameraView;
@property (strong, nonatomic) UIButton             *cancelButton;
@property (strong, nonatomic) QRCodeReader         *codeReader;
@property (assign, nonatomic) BOOL                 startScanningAtLoad;

@property (strong, nonatomic) UILabel              *labMyCode;
@property (strong, nonatomic) UIButton             *albumBtn;
@property (strong, nonatomic) UIButton             *backBtn;

#define   DeviceWidth         [[UIScreen mainScreen]bounds].size.width
#define   DeviceHeight        [[UIScreen mainScreen]bounds].size.height

@property (copy, nonatomic) void (^completionBlock) (NSString * __nullable);

@end

@implementation QRCodeReaderViewController

- (void)dealloc
{
    [self stopScanning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    return [self initWithCancelButtonTitle:nil];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle
{
    return [self initWithCancelButtonTitle:cancelTitle metadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
}

- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [self initWithCancelButtonTitle:nil metadataObjectTypes:metadataObjectTypes];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:metadataObjectTypes];
    
    return [self initWithCancelButtonTitle:cancelTitle codeReader:reader];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader
{
    return [self initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:true];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad
{
    if ((self = [super init])) {
        self.view.backgroundColor = [UIColor blackColor];
        self.codeReader           = codeReader;
        self.startScanningAtLoad  = startScanningAtLoad;
        
        if (cancelTitle == nil) {
            cancelTitle = NSLocalizedString(@"取消扫描", @"取消扫描");
        }
        
        [self setupUIComponentsWithCancelButtonTitle:cancelTitle];
        [self setupAutoLayoutConstraints];
        
        [_cameraView.layer insertSublayer:_codeReader.previewLayer atIndex:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        __weak typeof(self) weakSelf = self;
        
        [codeReader setCompletionWithBlock:^(NSString *resultAsString) {
            if (weakSelf.completionBlock != nil) {
                weakSelf.completionBlock(resultAsString);
            }
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(reader:didScanResult:)]) {
                [weakSelf.delegate reader:weakSelf didScanResult:resultAsString];
            }
        }];
    }
    return self;
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle];
}

+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle metadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReader *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:startScanningAtLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_startScanningAtLoad) {
        [self startScanning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopScanning];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _codeReader.previewLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Controlling the Reader

- (void)startScanning {
    [_codeReader startScanning];
    
    [_cameraView startScanning];
}

- (void)stopScanning {
    [_codeReader stopScanning];
    
    [_cameraView stopScanning];
}

#pragma mark - Managing the Orientation

- (void)orientationChanged:(NSNotification *)notification
{
    [_cameraView setNeedsDisplay];
    
    if (_codeReader.previewLayer.connection.isVideoOrientationSupported) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        _codeReader.previewLayer.connection.videoOrientation = [QRCodeReader videoOrientationFromInterfaceOrientation:
                                                                orientation];
    }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components

- (void)setupUIComponentsWithCancelButtonTitle:(NSString *)cancelButtonTitle
{
    self.cameraView                                       = [[QRCodeReaderView alloc] init];
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _cameraView.clipsToBounds                             = YES;
    [self.view addSubview:_cameraView];
    
    [_codeReader.previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if ([_codeReader.previewLayer.connection isVideoOrientationSupported]) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        _codeReader.previewLayer.connection.videoOrientation = [QRCodeReader videoOrientationFromInterfaceOrientation:orientation];
    }
    
    self.cancelButton                                       = [[UIButton alloc] init];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    
    /*----------------------------------  修改开始  -----------------------------------*/
    
#pragma mark--- 此处添加label   二维码/条形码扫描
    //self.view.sd_width/2, 20+49/2.0
    self.labMyCode=[[UILabel alloc]init];
    //_labMyCode.frame=CGRectMake([[UIScreen mainScreen]bounds].size.width/3, 25, 100, 30);
    _labMyCode.frame=CGRectMake(0, 0, DeviceWidth*0.72, 20);
    _labMyCode.center=CGPointMake(DeviceWidth/2 , 20+4+49/2.0);
    _labMyCode.backgroundColor=[UIColor clearColor];
    _labMyCode.textAlignment=NSTextAlignmentCenter;
    _labMyCode.font=[UIFont boldSystemFontOfSize:19.0];
    _labMyCode.textColor=[UIColor whiteColor];
    _labMyCode.text=@"二维码/条码";
    [self.view addSubview:_labMyCode];
    
#pragma mark--- 此处添加button  相册
    self.albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _albumBtn.frame=CGRectMake(0, 0, 45, 59);
    _albumBtn.center=CGPointMake(DeviceWidth-45, 20+4+59/2.0);
    [_albumBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    _albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [_albumBtn addTarget:self action:@selector(myAlbumClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_albumBtn];
    
#pragma mark--- 此处添加button  返回按钮
    self.backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame=CGRectMake(20, 30+4, 35, 25);
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    _backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [_backBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
}


#pragma mark--UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //1.获取选择的图片
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    //2.初始化一个监测器
    CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *featrues=[detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (featrues.count>=1) {
            CIQRCodeFeature *feature=[featrues objectAtIndex:0];
            NSString *scannedResult=feature.messageString;
            
            //            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            //            [alert show];
            
            if (_completionBlock) {
                _completionBlock(scannedResult);
            }
            if (_delegate && [_delegate respondsToSelector:@selector(reader:didImgPickerResult:)]) {
                [_delegate reader:self didImgPickerResult:scannedResult];
            }
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片不包含二维码/条码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*-----------------------------    修改结束   ------------------------------*/


- (void)setupAutoLayoutConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_cameraView, _cancelButton);
    
    
    if (IsiPhoneX) {
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView][_cancelButton(83)]|" options:0 metrics:nil views:views]];
    }else {
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView][_cancelButton(40)]|" options:0 metrics:nil views:views]];
    }
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelButton]-|" options:0 metrics:nil views:views]];
    
    if (_switchCameraButton) {
        NSDictionary *switchViews = NSDictionaryOfVariableBindings(_switchCameraButton);
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_switchCameraButton(50)]" options:0 metrics:nil views:switchViews]];
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_switchCameraButton(70)]|" options:0 metrics:nil views:switchViews]];
    }
}

- (void)switchDeviceInput
{
    [_codeReader switchDeviceInput];
}

#pragma mark - Catching Button Events

- (void)cancelAction:(UIButton *)button
{
    [_codeReader stopScanning];
    
    if (_completionBlock) {
        _completionBlock(nil);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(readerDidCancel:)]) {
        [_delegate readerDidCancel:self];
    }
}

- (void)myAlbumClick:(UIButton *)sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //1.初始化相册拾取器
        UIImagePickerController *controller=[[UIImagePickerController alloc]init];
        //2.设置代理
        controller.delegate=self;
        //3.设置资源
        controller.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        //4.随便一个转场动画
        controller.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)switchCameraAction:(UIButton *)button
{
    [self switchDeviceInput];
}

@end


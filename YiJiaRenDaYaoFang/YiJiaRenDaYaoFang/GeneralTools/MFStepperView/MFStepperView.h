//
//  MFStepperView.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 17/1/3.
//  Copyright © 2017年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXHRulerScrollView.h"

@class MFStepperView;

@interface MFStepperView : UIControl

@property (nonatomic, strong, readonly)UITextField *showTF;

- (instancetype)initWithMin:(float)min Max:(float)max;

@end

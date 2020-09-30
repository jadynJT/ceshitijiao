//
//  MeasureView.h
//  JuShanTangYaoDian
//
//  Created by apple on 16/12/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressView.h"

@protocol MeasureViewDelegate <NSObject>

- (void)onInstructionAction:(UIButton *)sender;
- (void)onStartBtnAction:(UIButton *)sender;
 
@end

@interface MeasureView : UIView


@property (nonatomic, strong)CircleProgressView *circleView;
@property (nonatomic, assign)Byte   *pressureByte;
@property (nonatomic, copy)NSString *dateStr;
@property (nonatomic, copy)NSString *timeStr;
@property (nonatomic, strong)UILabel *stateLabel;
@property (nonatomic, strong)UILabel *batteryValueLabel;
@property (nonatomic, strong)UILabel *BMPPowerLabel;
@property (nonatomic, strong)UIButton *instructionBtn;
@property (nonatomic, strong)UIImageView *bgImgView;
@property (nonatomic, strong)UIButton *startBtn;
@property (nonatomic, strong)UIImageView *batteryImgView;
@property (nonatomic, strong)UIImageView *blueToothImgView;

@property (nonatomic, weak)id<MeasureViewDelegate> delegate;

@end

//
//  MeasureView.m
//  JuShanTangYaoDian
//
//  Created by apple on 16/12/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "MeasureView.h"


@implementation MeasureView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

#pragma mark -- 初始化
- (CircleProgressView *)circleView{
    if (nil == _circleView) {
        _circleView = [[CircleProgressView alloc]init];
    }
    return _circleView;
}

- (UILabel *)stateLabel{
    if (nil == _stateLabel) {
        _stateLabel = [UILabel new];
        _stateLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _stateLabel.textAlignment=NSTextAlignmentLeft;
        [_stateLabel setBackgroundColor:[UIColor clearColor]];
        _stateLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
        _stateLabel.text = @"正在连接中..";
    }
    return _stateLabel;
}

- (UILabel *)batteryValueLabel{
    if (nil == _batteryValueLabel) {
        _batteryValueLabel = [UILabel new];
        _batteryValueLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _batteryValueLabel.textAlignment=NSTextAlignmentLeft;
        [_batteryValueLabel setBackgroundColor:[UIColor clearColor]];
        _batteryValueLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
        _batteryValueLabel.text = @"0%";
    }
    return _batteryValueLabel;
}




- (void)configUI{
    
    UIView *BMPMeasureV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    BMPMeasureV.backgroundColor = [UIColor whiteColor];
    [self addSubview:BMPMeasureV];
    
    //背景图
    _bgImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_background"]];
    _bgImgView.userInteractionEnabled = YES;
    [BMPMeasureV addSubview:_bgImgView];
    [_bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(BMPMeasureV).offset(0);
        make.width.equalTo(BMPMeasureV.mas_width);
        make.height.mas_equalTo(232/Proportion_height);
    }];
    [_bgImgView layoutIfNeeded];
    
    
    [_bgImgView addSubview:self.circleView];
    [_circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_bgImgView.mas_centerX);
        make.centerY.equalTo(_bgImgView.mas_centerY);
        make.width.and.height.mas_equalTo(176/Proportion_height);
    }];
    [_circleView layoutIfNeeded];
    
    
    UIView *leftView = [UIView new];
    leftView.layer.borderWidth = 0.3;
    leftView.layer.borderColor = [UIColorFromRGBA(0xe1e1e1, 1.0)CGColor];
    [BMPMeasureV addSubview:leftView];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(BMPMeasureV).offset(0);
        make.top.equalTo(_bgImgView.mas_bottom).offset(0);
        make.width.mas_equalTo(self.bounds.size.width/2);
        make.height.mas_equalTo(86/Proportion_height);
    }];
    [leftView layoutIfNeeded];
    
    //测量说明btn
    _instructionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_instructionBtn setBackgroundImage:[UIImage imageNamed:@"btn_instruction"] forState:UIControlStateNormal];
    [_instructionBtn addTarget:self action:@selector(onInstructionAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImgView addSubview:_instructionBtn];
    [_instructionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bgImgView.mas_top).offset(10);
        make.right.equalTo(_bgImgView.mas_right).offset(-10);
        make.width.and.height.mas_equalTo(40/Proportion_height);
    }];
    
    
    
    _blueToothImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_bluetooth"]];
    [leftView addSubview:_blueToothImgView];
    [_blueToothImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView).offset(20/Proportion_height);
        make.top.equalTo(leftView).offset(20/Proportion_height);
        make.height.and.width.mas_equalTo(20/Proportion_height);
    }];
    [_blueToothImgView layoutIfNeeded];
    
    
    //蓝牙连接状态
    UILabel *connectStateLabel = [UILabel new];
    connectStateLabel.font = [UIFont boldSystemFontOfSize:15.0];
    connectStateLabel.text = @"蓝牙连接状态";
    connectStateLabel.textAlignment=NSTextAlignmentLeft;
    [connectStateLabel setBackgroundColor:[UIColor clearColor]];
    connectStateLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [leftView addSubview:connectStateLabel];
    
    [connectStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_blueToothImgView.mas_right).offset(16/Proportion_height);
        make.top.equalTo(leftView).offset(20/Proportion_height);
        make.right.equalTo(leftView).offset(0);
        make.height.mas_equalTo(20/Proportion_height);
    }];
    [connectStateLabel layoutIfNeeded];
    
    //蓝牙状态
    
    [leftView addSubview:self.stateLabel];
    [_stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(leftView).offset(0);
        make.top.equalTo(connectStateLabel.mas_bottom).offset(14/Proportion_height);
        make.width.equalTo(connectStateLabel.mas_width);
        make.height.mas_equalTo(18/Proportion_height);
    }];
    
    /*********************************************************************/
    //右侧label
    UIView *rightView = [UIView new];
    rightView.layer.borderWidth = 0.3;
    rightView.layer.borderColor = [UIColorFromRGBA(0xe1e1e1, 1.0)CGColor];
    
    [BMPMeasureV addSubview:rightView];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right).offset(0);
        make.top.equalTo(_bgImgView.mas_bottom).offset(0);
        make.width.mas_equalTo(UISCREEN_BOUNCES.size.width/2);
        make.height.equalTo(leftView.mas_height);
    }];
    [rightView layoutIfNeeded];
    
    _batteryImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_battery"]];
    [rightView addSubview:_batteryImgView];
    [_batteryImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightView).offset(20/Proportion_height);
        make.top.equalTo(rightView).offset(20/Proportion_height);
        make.height.and.width.mas_equalTo(_blueToothImgView);
    }];
    [_batteryImgView layoutIfNeeded];
    
    //血压计电量
    _BMPPowerLabel = [UILabel new];
    _BMPPowerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _BMPPowerLabel.text = @"血压计电量";
    _BMPPowerLabel.textAlignment=NSTextAlignmentLeft;
    [_BMPPowerLabel setBackgroundColor:[UIColor clearColor]];
    _BMPPowerLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    [rightView addSubview:_BMPPowerLabel];
    
    [_BMPPowerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_batteryImgView.mas_right).offset(16/Proportion_height);
        make.top.equalTo(rightView).offset(20/Proportion_height);
        make.width.and.height.equalTo(connectStateLabel);
    }];
    [_BMPPowerLabel layoutIfNeeded];
    
    UIImageView *battery_fullImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"battery_full"]];
    [rightView addSubview:battery_fullImgView];
    [battery_fullImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_BMPPowerLabel.mas_left).offset(0);
        make.top.equalTo(_BMPPowerLabel.mas_bottom).offset(14/Proportion_height);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(16);
    }];
    [battery_fullImgView layoutIfNeeded];
    
    //电量值
    
    [rightView addSubview:self.batteryValueLabel];
    [_batteryValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(battery_fullImgView.mas_right).offset(10/Proportion_height);
        make.top.equalTo(_BMPPowerLabel.mas_bottom).offset(14/Proportion_height);
        make.height.mas_equalTo(_batteryValueLabel.mas_height);
    }];
    [_batteryValueLabel layoutIfNeeded];
    
    
    //tip
    UILabel *tipLabel = [UILabel new];
    tipLabel.font = [UIFont boldSystemFontOfSize:18.0];
    tipLabel.text = @"测量中请保持安静！";
    tipLabel.textAlignment=NSTextAlignmentCenter;
    tipLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    tipLabel.backgroundColor = [UIColor clearColor];
    [BMPMeasureV addSubview:tipLabel];
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftView.mas_bottom).offset(44/Proportion_height);
        make.width.mas_equalTo(UISCREEN_BOUNCES.size.width);
        make.height.mas_equalTo(20/Proportion_height);
    }];
    [tipLabel layoutIfNeeded];
    
    //开始测量
    _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startBtn setTitle:@"开始测量" forState:UIControlStateNormal];
    _startBtn.contentMode=UIViewContentModeScaleAspectFit;
    _startBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [_startBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_startBtn addTarget:self action:@selector(onStartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [BMPMeasureV addSubview:_startBtn];
    [_startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(123);
        make.height.mas_equalTo(34);
        make.top.equalTo(tipLabel.mas_bottom).offset(44/Proportion_height);
        make.left.equalTo(BMPMeasureV).offset(UISCREEN_BOUNCES.size.width/2.0-123/2.0);
    }];
    [_startBtn layoutIfNeeded];

}


- (void)onInstructionAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onInstructionAction:)]) {
        [self.delegate onInstructionAction:sender];
    }
}

- (void)onStartBtnAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStartBtnAction:)]) {
        [self.delegate onStartBtnAction:sender];
    }
}


@end

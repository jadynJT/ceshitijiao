//
//  MFStepperView.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 17/1/3.
//  Copyright © 2017年 TW. All rights reserved.
//

#import "MFStepperView.h"
#import "TXHRulerScrollView.h"

@interface MFStepperView()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UILabel *unitLab;
@property (nonatomic, assign) float minimumNum;
@property (nonatomic, assign) float maxNum;

@end

@implementation MFStepperView

- (instancetype)initWithMin:(float)min Max:(float)max{
    if (self == [super init ]) {
        _minimumNum = min;
        _maxNum = max;
        
        [self setupUI];
        [self autoLayout];
    }
    return self;
}

- (void)setupUI{
    _showTF = [[UITextField alloc]init];
    _showTF.textAlignment = NSTextAlignmentCenter;
    _showTF.textColor = UIColorFromRGBA(0x646464, 0.8);
    _showTF.font = [UIFont systemFontOfSize:50.0];
    _showTF.backgroundColor = [UIColor clearColor];
    _showTF.delegate = self;
    _showTF.tag = 320;
    _showTF.enabled = NO;
    
    [self addSubview:self.showTF];
    [self addSubview:self.unitLab];
    [self addSubview:self.addBtn];
    [self addSubview:self.deleteBtn];
    if ([_showTF.text floatValue] == _minimumNum) {
        self.deleteBtn.enabled = NO;
    }
}

#pragma mark - 初始化

- (UILabel *)unitLab{
    if (!_unitLab) {
        _unitLab = [[UILabel alloc]init];
        _unitLab.text = @"mmol/L";
        _unitLab.textAlignment = NSTextAlignmentCenter;
        _unitLab.textColor = UIColorFromRGBA(0xbababa, 0.8);
        _unitLab.font = [UIFont systemFontOfSize:16.0];
        _unitLab.backgroundColor = [UIColor clearColor];
    }
    return _unitLab;
}

- (UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _addBtn.frame = CGRectMake(0, 0, 35, self.showTF.frame.size.height);
        [_addBtn setImage:[UIImage imageNamed:@"add_blue"] forState:UIControlStateNormal];
        [_addBtn setImage:[UIImage imageNamed:@"add_hui"] forState:UIControlStateDisabled];
        [_addBtn setImage:[UIImage imageNamed:@"add_blue"] forState:UIControlStateHighlighted];
        [_addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"jian_blue"] forState:UIControlStateNormal];
        [_deleteBtn setImage:[UIImage imageNamed:@"jian_hui"] forState:UIControlStateDisabled];
        [_deleteBtn setImage:[UIImage imageNamed:@"jian_blue"] forState:UIControlStateHighlighted];
        [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (void)addAction:(UIButton *)sender{
    
    NSString * changeStr = self.showTF.text;
    if ([changeStr floatValue] >= 0  && ([changeStr floatValue] < _maxNum)) {
        self.showTF.text = [NSString stringWithFormat:@"%.1f",[changeStr floatValue]+0.1];
        [Utility changeColor:self.showTF];
        if ([self.showTF.text floatValue] == _maxNum) {
            self.addBtn.enabled = NO;
            self.deleteBtn.enabled = YES;
        }
        if ([self.showTF.text floatValue] > _minimumNum) {
            self.deleteBtn.enabled = YES;
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)deleteAction:(UIButton *)sender{
    [self.showTF resignFirstResponder];
    NSString * changeStr = self.showTF.text;
    if ([changeStr floatValue] > 0.19 && [changeStr floatValue] <= _maxNum) {
        self.showTF.text = [NSString stringWithFormat:@"%.1f",[changeStr floatValue]-0.1];
    }
    
    if ([changeStr floatValue] <= 0.1) {
        self.showTF.text = [NSString stringWithFormat:@"%.1f",[changeStr floatValue]];
    }
    
    [Utility changeColor:self.showTF];
    if ([self.showTF.text floatValue] == _minimumNum) {
        self.deleteBtn.enabled = NO;
        self.addBtn.enabled = YES;
    }
    if ([self.showTF.text floatValue] < _maxNum) {
        self.addBtn.enabled = YES;
    }

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)autoLayout{
    [self.showTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(200);
        make.centerX.equalTo(self.mas_centerX).offset(0);
        make.centerY.equalTo(self.mas_centerY).offset(0);
    }];
    [self.showTF layoutIfNeeded];
    
    [self.unitLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.top.equalTo(self.showTF.mas_bottom).offset(0);
        make.centerX.equalTo(self.mas_centerX).offset(0);
    }];
    [self.unitLab layoutIfNeeded];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(35);
        make.right.equalTo(self.showTF.mas_left).offset(0);
        make.centerY.equalTo(self.mas_centerY).offset(0);
    }];
    [self.deleteBtn layoutIfNeeded];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(35);
        make.left.equalTo(self.showTF.mas_right).offset(0);
        make.centerY.equalTo(self.mas_centerY).offset(0);
    }];
    [self.addBtn layoutIfNeeded];
}

@end

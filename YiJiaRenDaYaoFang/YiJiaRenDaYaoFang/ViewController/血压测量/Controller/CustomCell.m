//
//  CustomCell.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/6/22.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.textColor = UIColorFromRGBA(0x646464, 0.8);
    self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputTextField.textAlignment = NSTextAlignmentCenter;
    self.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(28);
        make.left.equalTo(self.contentView.mas_left).offset(16/Proportion_height);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
        
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgView.mas_right).offset(16/Proportion_height);
        make.height.mas_equalTo(18/Proportion_height);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];

    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
    }];

    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.unitLabel.mas_left).offset(-5);
        make.left.equalTo(self.contentView.mas_left).offset(UISCREEN_BOUNCES.size.width/2.0);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

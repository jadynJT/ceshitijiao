//
//  CustomSearchResultCell.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/7/2.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "CustomSearchResultCell.h"

@implementation CustomSearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 会员卡号或电话号码
        _phoneImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_phone"]];
        [self.contentView addSubview:_phoneImgView];
        
        [_phoneImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(40);
            make.left.equalTo(self.contentView.mas_left).offset(10/Proportion_height);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        // label
        _phoneNumLabel = [UILabel new];
        _phoneNumLabel.font = [UIFont boldSystemFontOfSize:19.0];
        _phoneNumLabel.textColor = UIColorFromRGBA(0x3c3c3c, 0.7);
        [self.contentView addSubview:_phoneNumLabel];
        
        [_phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_phoneImgView.mas_right).offset(10/Proportion_height);
            make.height.mas_equalTo(30/Proportion_height);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        // 测量btn
        _measureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _measureBtn.contentMode=UIViewContentModeScaleAspectFit;
        [_measureBtn setTitleColor:UIColorFromRGBA(0x45bafb, 1.0) forState:UIControlStateNormal];
        _measureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
        [_measureBtn setTitle:@"测量" forState:UIControlStateNormal];
        [self.contentView addSubview:_measureBtn];
        [self.measureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(60);
            make.right.equalTo(self).offset(-20/Proportion_height);
            make.centerY.equalTo(self.mas_centerY);
        }];
        [self.measureBtn layoutIfNeeded];

        // 测量
        _measureImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_measure"]];
        [self.contentView addSubview:_measureImgView];
        
        [self.measureImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(30);
            make.right.equalTo(_measureBtn.mas_left).offset(-10/Proportion_height);
            make.centerY.equalTo(self.mas_centerY);
        }];
        [self.measureImgView layoutIfNeeded];   
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

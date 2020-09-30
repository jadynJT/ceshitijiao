//
//  LaunchScreenIntroCollectionViewCell.m
//  YiJiaRenDaYaoFang
//
//  Created by libz on 17/1/3.
//  Copyright © 2017年 Nenglong. All rights reserved.
//

#import "UserGuideIntroCell.h"
#import "Masonry.h"

@interface UserGuideIntroCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation UserGuideIntroCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.dismissButton];
        self.backgroundColor = [UIColor clearColor];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(@0);
        }];
        
        [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@(self.contentView.frame.size.height*0.16));
            make.bottom.equalTo(self.contentView).offset(0);
        }];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (void)setImageName:(NSString *)imageName {
    if (_imageName != imageName) {
        _imageName = [imageName copy];
        
        if ([Utility isIPhone5] || [Utility isIPhone6]) {
            _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-568h",imageName]];
        }else
        {
            _imageView.image = [UIImage imageNamed:imageName];
        }
    }
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton addTarget:self action:@selector(dismissButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (void)dismissButtonTapped:(id)sender {
    if (self.dismissButtonAction) {
        self.dismissButtonAction();
    }
}

@end

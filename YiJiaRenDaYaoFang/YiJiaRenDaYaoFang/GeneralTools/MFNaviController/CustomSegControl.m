//
//  CustomSegControl.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/12/31.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "CustomSegControl.h"
#import "UIView+Layer.h"
#import "UIView+Frame.h"

#define kCommonTintColor [UIColor colorWithRed:0.42f green:0.33f blue:0.27f alpha:1.00f]
#define kCommonBgColor [UIColor colorWithRed:0.86f green:0.85f blue:0.80f alpha:1.00f]
/***  普通字体 */
#define kFont(size) [UIFont systemFontOfSize:size]

@implementation CustomSegControl {
    NSArray *_itemTitles;
    UIButton *_selectedBtn;
}

- (instancetype)initWithItemTitles:(NSArray *)itemTitles {
    if (self = [super init]) {
        _itemTitles = itemTitles;
        
        self.layerCornerRadius = 15.0;
        self.layerBorderColor = [UIColor whiteColor];
        self.layerBorderWidth = 1.0;
        
        [self setUpViews];
    }
    return self;
}

- (void)clickDefault {
    if (_itemTitles.count == 0) {
        return ;
    }
    [self btnClick:(UIButton *)[self viewWithTag:1]];
}

- (void)setUpViews {
    
    if (_itemTitles.count > 0) {
        NSInteger i = 0;
        for (id obj in _itemTitles) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *objStr = (NSString *)obj;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [self addSubview:btn];
                btn.backgroundColor = UIColorFromRGBA(0X333333, 0);
                [btn setTitle:objStr forState:UIControlStateNormal];
                [btn setTitleColor:UIColorFromRGBA(0x333333, 1.0) forState:UIControlStateSelected];
                [btn setTitleColor:UIColorFromRGBA(0xcccccc, 1.0) forState:UIControlStateNormal];
                btn.titleLabel.font = kFont(16);
                i = i + 1;
                btn.tag = i;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                btn.adjustsImageWhenDisabled = NO;
                btn.adjustsImageWhenHighlighted = NO;
            }
        }
    }
}

- (void)btnClick:(UIButton *)btn {
    _selectedBtn.backgroundColor = UIColorFromRGBA(0X333333, 0);
    btn.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
    _selectedBtn.selected = NO;
    btn.selected = YES;
    _selectedBtn = btn;
    
    NSString *title = btn.currentTitle;
    if (self.CustomSegmentViewBtnClickHandle) {
        self.CustomSegmentViewBtnClickHandle(self, title, btn.tag - 1);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_itemTitles.count > 0) {
        CGFloat btnW = self.width / _itemTitles.count;
        for (int i = 0 ; i < _itemTitles.count; i++) {
            UIButton *btn = (UIButton *)[self viewWithTag:i + 1];
            btn.frame = CGRectMake(btnW * i, 0, btnW, self.height);
        }
    }
}

@end

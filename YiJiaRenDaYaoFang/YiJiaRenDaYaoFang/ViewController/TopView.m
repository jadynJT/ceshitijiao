//
//  TopView.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2018/7/23.
//  Copyright © 2018年 TW. All rights reserved.
//

#import "TopView.h"

@interface TopView ()

@end

@implementation TopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加按钮
        UIButton *returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, (self.frame.size.height-35)/2, 35, 35)];
        [returnBtn setTitle:@"返回" forState:UIControlStateNormal];
        returnBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [returnBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [returnBtn addTarget:self action:@selector(returnSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:returnBtn];
        
        // 添加底部分隔线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, Screen_width, 0.5)];
        lineView.backgroundColor = [UIColor colorWithRed:197/255.0 green:197/255.0 blue:197/255.0 alpha:1];
        [self addSubview:lineView];
    }
    return self;
}

- (void)returnSelect:(id)sender {
    self.returnBlock ? self.returnBlock() : nil;
}

@end

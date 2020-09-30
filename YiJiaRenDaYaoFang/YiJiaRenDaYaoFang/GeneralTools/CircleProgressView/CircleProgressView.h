//
//  CircleProgressView.h
//  BaiXingDaYaoFang
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleProgressView : UIView

@property (nonatomic,assign) float haveFinished;
@property (nonatomic,assign) CGRect rect;

@property (nonatomic,assign) float strokeStart;
@property (nonatomic,assign) float strokeEnd;

@property (nonatomic,assign) float lineWidth;
@property (nonatomic,strong) UILabel *countlabel;
@property (nonatomic,strong) UILabel *unitLabel;
@end

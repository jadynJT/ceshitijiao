//
//  CircleProgressView.m
//  BaiXingDaYaoFang
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "CircleProgressView.h"

@interface CircleProgressView() {
    NSMutableString * str;
    NSString *resultStr;
}
//创建全局属性
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer2;
@property (nonatomic, strong) CAShapeLayer *cycleLayer;
@property (nonatomic, strong) UIView* roundView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) int   increase;

@end

@implementation CircleProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setPercent:(float)haveFinished{
    self.haveFinished = haveFinished;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [self initData];
}

- (void)initData {
    resultStr = [NSString stringWithFormat:@"%0.2f",self.haveFinished];
    
    self.rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);;
    self.lineWidth = 10.0f;
    _increase = 0;
    [self circleAnimationTypeOne];
    [self addLabel];
    if (_haveFinished > 0) {
        [self animation];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.04
                                              target:self
                                            selector:@selector(numShow)
                                            userInfo:nil
                                             repeats:YES];
}


- (void)circleAnimationTypeOne
{
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.rect;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色(背景灰色)
    self.shapeLayer.lineWidth = self.lineWidth-5;
    self.shapeLayer.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3].CGColor;
    
    //创建出圆形贝塞尔曲线
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.rect.size.width / 2, self.rect.size.height / 2 )radius:self.rect.size.height / 2 startAngle:M_PI_2 endAngle:2.5*M_PI  clockwise:YES];
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = circlePath.CGPath;
    
    //添加并显示
    [self.layer addSublayer:self.shapeLayer];
    
    UIBezierPath* circlePath2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.rect.size.width / 2, self.rect.size.height / 2 )radius:self.rect.size.height / 2 startAngle:M_LN10 endAngle:2*M_PI*_haveFinished+M_LN10 clockwise:YES];
    
    //创建出CAShapeLayer
    self.shapeLayer2 = [CAShapeLayer layer];
    self.shapeLayer2.frame = self.rect;
    
    self.shapeLayer2.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色（白色）
    self.shapeLayer2.lineWidth = self.lineWidth;
    self.shapeLayer2.strokeColor = UIColorFromRGBA(0xFFFFFF, 1.0).CGColor;
    self.shapeLayer2.lineCap = kCALineCapRound;
    self.shapeLayer2.lineJoin = kCALineJoinRound;
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer2.path = circlePath2.CGPath;
    
    //添加并显示
    [self.layer addSublayer:self.shapeLayer2];
}

- (void)animation {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 4*self.haveFinished;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1];
    pathAnimation.autoreverses = NO;
    
    
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyAnimation.path=self.shapeLayer2.path;
    keyAnimation.fillMode = kCAFillModeForwards;
    keyAnimation.calculationMode = kCAAnimationPaced;
    keyAnimation.duration = 4*self.haveFinished;
    keyAnimation.removedOnCompletion = NO;
    [self.shapeLayer2 addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    [_roundView.layer addAnimation:keyAnimation forKey:nil];
}

- (void)addLabel {
    if (!_unitLabel) {
        _unitLabel = [UILabel new];
        _unitLabel.frame = CGRectMake(0, 0, 180, 40);
        CGPoint point3 =  CGPointMake(self.shapeLayer.position.x, self.shapeLayer.position.y + 25);
        _unitLabel.center = point3;
        _unitLabel.text = @"mmHg";
        _unitLabel.textAlignment = NSTextAlignmentCenter;
        _unitLabel.font = [UIFont systemFontOfSize:19];
        _unitLabel.textColor =  UIColorFromRGBA(0xFFFFFF, 0.8);
        [self addSubview:_unitLabel];
    }
    
    if (!_countlabel) {
        _countlabel = [UILabel new];
        self.countlabel.frame = CGRectMake(0,0,180,40);
        CGPoint point2 =  CGPointMake(self.shapeLayer.position.x, self.shapeLayer.position.y-15);
        _countlabel.center =  point2;
        str=[[NSMutableString alloc]init];
        _countlabel.textAlignment = NSTextAlignmentCenter;
        _countlabel.font = [UIFont systemFontOfSize:45];
        _countlabel.textColor =  UIColorFromRGBA(0xFFFFFF, 1.0);
        _countlabel.text = @"0";
        [self addSubview:_countlabel];
    }
}

- (void)numShow {
    if (self.haveFinished < 0) {
        [_timer invalidate];
        return;
    }
    if (self.haveFinished <= 0.01) {
        [_timer invalidate];
        return;
    }
    if (_increase >= 100*self.haveFinished) {
        [_timer invalidate];
        return;
    }
    _increase += 1;
}


@end

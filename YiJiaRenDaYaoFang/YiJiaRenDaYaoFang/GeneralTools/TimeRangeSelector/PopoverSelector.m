//
//  PopoverSelector.m
//  ByqIOSApps
//
//  Created by DumbbellYang on 15/3/3.
//  Copyright (c) 2015年 [云智汇 移动应用]. All rights reserved.
//

#import "PopoverSelector.h"
#import <QuartzCore/QuartzCore.h>

@interface PopoverSelector ()

- (void)defalutInit;
- (void)fadeIn;
- (void)fadeOut;

- (void)initWithType:(TimeRangeType)rangeType;

@end

@implementation PopoverSelector

@synthesize selectDelegate = _selectorDelegate;
@synthesize rangePicker = _rangePicker;

@synthesize data = _data;
@synthesize dataSeparator = _dataSeparator;
@synthesize pickerData = _pickerData;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initSelectorWithFrameTypeData:(CGRect)frame SelectorData:(NSMutableArray*)selectorData{
    self = [super initWithFrame:frame];
    if (self) {
        [self setData:selectorData];
        [self setDataSeparator:@"-"]; //缺省数据分隔符
        
        [self defalutInit];
    }
    return self;
}

- (void)defalutInit{
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = TRUE;
    
    _titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleView.font = [UIFont systemFontOfSize:17.0f];
    _titleView.backgroundColor = [UIColor colorWithRed:59./255.
                                                 green:89./255.
                                                  blue:152./255.
                                                 alpha:1.0f];
    
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.textColor = [UIColor whiteColor];
    CGFloat xWidth = self.bounds.size.width;
    _titleView.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleView.frame = CGRectMake(0, 0, xWidth, 32.0f);
    
    [self addSubview:_titleView];
    
    CGRect selectorFrame = CGRectMake(0, 32.0f, xWidth, self.bounds.size.height-32.0f);
    
    //时间范围选择
    _rangePicker = [[TimeRangePicker alloc]initWithFrame:selectorFrame];
        
    [_rangePicker setHidden:NO];
    
    [_rangePicker setIsShowYear:YES];
    [_rangePicker setShowView:_titleView];
    [_rangePicker setIsShowChinese:NO];
       
    _overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //_overlayView.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
    _overlayView.backgroundColor = [UIColor redColor];
    
    [_overlayView addTarget:self
                     action:@selector(dismiss)
           forControlEvents:UIControlEventTouchUpInside];
}

- (id)initSelectorWithFrameRangeType:(CGRect)frame RangeType:(TimeRangeType)rangeType{
    self = [super initWithFrame:frame];
    if (self) {
        [self setData:nil];
        [self setDataSeparator:@"-"]; //缺省数据分隔符
        
        [self initWithType:rangeType];
    }
    return self;
}

- (void)initWithType:(TimeRangeType)rangeType{
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = TRUE;
    
    _titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleView.font = [UIFont systemFontOfSize:17.0f];
    _titleView.backgroundColor = [UIColor colorWithRed:59./255.
                                                 green:89./255.
                                                  blue:152./255.
                                                 alpha:1.0f];
    
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.textColor = [UIColor whiteColor];
    CGFloat xWidth = self.bounds.size.width;
    _titleView.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleView.frame = CGRectMake(0, 0, xWidth, 32.0f);
    [self addSubview:_titleView];
    
    CGRect selectorFrame = CGRectMake(0, 32.0f, xWidth, self.bounds.size.height-32.0f);
    
    //时间范围选择
    _rangePicker = [[TimeRangePicker alloc]initWithFrame:selectorFrame];
    
    [_rangePicker setHidden:NO];
    //[_rangePicker setPickerFormat:@"hh:mm"];
    [self setRangeType:_rangePicker RangeType:rangeType];
    
    [_rangePicker setShowView:_titleView];
    [_rangePicker setIsShowChinese:NO];
    
    _overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _overlayView.backgroundColor = UIColorFromRGBA(0x000000, .7);
    [_overlayView addTarget:self
                     action:@selector(dismiss)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void) setRangeType:(TimeRangePicker*)picker RangeType:(TimeRangeType)rangeType{
    [picker setIsShowYear:NO];
    [picker setIsShowMonth:NO];
    [picker setIsShowDay:NO];
    [picker setIsShowHour:NO];
    [picker setIsShowMinute:NO];
    [picker setIsShowSecond:NO];
    
    switch (rangeType) {
        case YYYYMMDD:
            [picker setIsShowYear:YES];
            [picker setIsShowMonth:YES];
            [picker setIsShowDay:YES];
            break;
            
        case YYYYMMDDHHMM:
            [picker setIsShowYear:YES];
            [picker setIsShowMonth:YES];
            [picker setIsShowDay:YES];
            [picker setIsShowHour:YES];
            [picker setIsShowMinute:YES];
            break;
            
        case YYYYMMDDHHMMSS:
            [picker setIsShowYear:YES];
            [picker setIsShowMonth:YES];
            [picker setIsShowDay:YES];
            [picker setIsShowHour:YES];
            [picker setIsShowMinute:YES];
            [picker setIsShowSecond:YES];
            break;
        default:
            break;
    }
}

#pragma mark - animations
- (void)fadeIn{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [_overlayView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)setTitle:(NSString *)title{
    _titleView.text = title;
}

- (NSString*)getTitle{
    return _titleView.text;
}

- (void)show{
    [self.rangePicker show:self];

    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:_overlayView];
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f,
                              keywindow.bounds.size.height/2.0f);
    [self fadeIn];
}

- (void)dismiss{
    if ([Utility compareOneDay:[Utility changeSpToTime:_titleView.text] withAnotherDay:[NSDate date]] == 1){
        [SVProgressHUD showInfoWithStatus:@"所选时间大于当前时间"];
    }
    if (self.selectDelegate && [self.selectDelegate respondsToSelector:@selector(itemSelected:SelectedItem:)]) {
        [self.selectDelegate itemSelected:self SelectedItem:[_titleView text]];
    }
    
    [self fadeOut];
}

#define mark - UITouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // tell the delegate the cancellation
    // dismiss self
    [self dismiss];
}

@end


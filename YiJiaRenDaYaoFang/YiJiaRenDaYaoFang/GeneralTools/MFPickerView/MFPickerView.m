//
//  MFPickerView.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/12/30.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "MFPickerView.h"
#define SCREENSIZE UIScreen.mainScreen.bounds.size

@implementation MFPickerView{
    UIView    *bgView;
    NSArray   *proTitleList;
    NSString  *selectedStr;
    NSInteger index;
}

@synthesize block;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}

- (void)showPickView:(UIView *)vc
{
    bgView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.3f;
    [vc addSubview:bgView];
    
    CGRect frame = self.frame;
    self.frame = CGRectMake(0,SCREENSIZE.height + frame.size.height, SCREENSIZE.width, frame.size.height);
    [vc addSubview:self];
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.frame = frame;
                     }
                     completion:nil];
}

- (void)hide
{
    [bgView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)setDataViewWithItem:(NSArray *)items title:(NSString *)title
{
    proTitleList = items;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, 39.5)];
    header.backgroundColor = UIColorFromRGBA(0xFFFFEF, 1);
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREENSIZE.width - 80, 39.5)];
    titleLbl.text = title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [self getColor:@"FF8000"];
    titleLbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    [header addSubview:titleLbl];
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(SCREENSIZE.width - 50, 10, 50 ,29.5)];
    [submit setTitle:@"确定" forState:UIControlStateNormal];
    [submit setTitleColor:UIColorFromRGBA(0x47B6EF, 0.8) forState:UIControlStateNormal];
    submit.backgroundColor = [UIColor clearColor];
    submit.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    [submit addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:submit];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 50 ,29.5)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:cancel];
    
    [self setTheLineImg:39.5];
    
    [self addSubview:header];
    UIPickerView *pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, SCREENSIZE.width, 210)];
    
    pick.delegate = self;
    pick.backgroundColor = UIColorFromRGBA(0xFFFFFF, 1);
    [self addSubview:pick];
    
    float height = 250;
    self.frame = CGRectMake(0, SCREENSIZE.height - height, SCREENSIZE.width, height);
}

#pragma mark - DatePicker监听方法
- (void)cancel:(UIButton *)btn
{
    [self hide];
}

- (void)submit:(UIButton *)btn
{
    NSString *pickStr = selectedStr;
    if (!pickStr || pickStr.length == 0) {
        if ([proTitleList count] > 0) {
                selectedStr = proTitleList[0];
                index = [Utility getIndex:selectedStr];
        }
    }
    block(@{@"selectStr":selectedStr,@"selectIndex":[NSNumber numberWithInteger:index]});
    [self hide];
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [proTitleList count];
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedStr = [proTitleList objectAtIndex:row];
    index = [Utility getIndex:selectedStr];
}

// 返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [proTitleList objectAtIndex:row];
    
}
- (UIColor *)getColor:(NSString*)hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

- (CGSize)workOutSizeWithStr:(NSString *)str andFont:(NSInteger)fontSize value:(NSValue *)value{
    CGSize size;
    if (str) {
        NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName, nil];
        size=[str boundingRectWithSize:[value CGSizeValue] options:NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    }
    return size;
}

// 设置横线
- (void)setTheLineImg:(float )sizeY {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, sizeY, SCREENSIZE.width , 1)];
    imgView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
    [self addSubview:imgView];
}



@end

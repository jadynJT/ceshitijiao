//
//  BloodGlucose.m
//  JuShanTangYaoDian
//
//  Created by apple on 16/12/29.
//  Copyright © 2016年 TW. All rights reserved.
//
//血糖手动测量页面

#import "BloodGlucose.h"
#import "MFPickerView.h"
#import "MeasurePageViewController.h"


@implementation BloodGlucose

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = [UIColor whiteColor];
    
    // 1.创建一个显示的标签
    [self addSubview:self.stepperView];
    [_stepperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(50);
    }];
    [_stepperView layoutIfNeeded];
    
    // 2.创建 TXHRrettyRuler 对象 并设置代理对象
    _ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(20, 20+15+50, self.bounds.size.width - 20 * 2, 110)];
    _ruler.rulerDeletate = self;
    [_ruler showRulerScrollViewWithCount:333 average:[NSNumber numberWithFloat:0.1] currentValue:6.1f smallMode:YES];
    [self addSubview:_ruler];
       
    
    //3.
    [self addSubview:self.tipLab];
    [_tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(10);
        make.top.equalTo(_ruler.mas_bottom).offset(0);
    }];

    [self addSubview:self.tableV];
    [_tableV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tipLab.mas_bottom).offset(20);
        make.left.and.right.equalTo(self).offset(0);
        make.height.mas_equalTo(100);
    }];
    
    [self addSubview:self.saveBtn];
    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(123);
        make.height.mas_equalTo(34);
        make.centerX.equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.tableV.mas_bottom).offset(44);
    }];
    
    _curDate = [NSDate date];
    
    [self.stepperView addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - 初始化
- (NSMutableArray *)picTitleArr {
    if (!_picTitleArr) {
        _picTitleArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _picTitleArr;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _tipLab.font = [UIFont boldSystemFontOfSize:13.0];
        _tipLab.text = @"左右滑动改变血糖值";
        [_tipLab setBackgroundColor:[UIColor clearColor]];
        _tipLab.textColor = UIColorFromRGBA(0x646464, 0.4);
        _tipLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLab;
}

- (MFStepperView *)stepperView {
    if (nil == _stepperView) {
        _stepperView = [[MFStepperView alloc]initWithMin:0.1 Max:33.3];
        _stepperView.showTF.text = @"6.1";
    }
    return _stepperView;
}

- (NSArray *)arr {
    if (nil == _arr) {
        _arr = [[NSArray alloc]initWithObjects:@"测量时间",@"测量点", nil];
    }
    return _arr;
}

- (UITableView *)tableV {
    if (nil == _tableV) {
        _tableV = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableV.scrollEnabled = NO;
        _tableV.delegate = self;
        _tableV.dataSource = self;
    }
    return  _tableV;
}

- (UIButton *)saveBtn {
    if (nil == _saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setBackgroundImage:[UIImage imageNamed:@"button_glucose"] forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
        [_saveBtn setTitle:@"保存记录" forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(onSaveAction:) forControlEvents:UIControlEventTouchUpInside];
        _saveBtn.tag = 301;
    }
    return _saveBtn;
}

#pragma mark - 界面
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strIdentity = @"defaultCellIdentity";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strIdentity];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:strIdentity];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.arr[indexPath.row];
    
    if (0 == indexPath.row) {
        if (0 == cell.detailTextLabel.text.length) {
            _measureTime = [Utility dateToString:_curDate];
            cell.detailTextLabel.text = _measureTime;
            cell.detailTextLabel.tag = 204;
        }
    }else if (1 == indexPath.row){
        if (0 == cell.detailTextLabel.text.length) {
            NSDate *date = [Utility getLocalDateFromatAnDate:[NSDate date]];
            cell.detailTextLabel.text = [[[[Utility alloc]init] getTheTimeBucket:date]objectForKey:@"selectStr"];
            _measureTimeSlot = [[[[Utility alloc]init] getTheTimeBucket:date]objectForKey:@"selectIndex"];
            self.picTitleArr = [[[[Utility alloc]init]getTheTimeBucket:date] objectForKey:@"pickerArr"];
            
            cell.detailTextLabel.tag = 205;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        //测量时间
        [self showTimeRangeSelector:YYYYMMDDHHMM];
        
    }else if (1 == indexPath.row){
        //测量点
        [self showTimeSlot];
    }
}

#pragma mark - TXHRrettyRulerDelegate

- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.stepperView.showTF.text = [NSString stringWithFormat:@"%.1f",rulerScrollView.rulerValue];
    [Utility changeColor:self.stepperView.showTF];
}

#pragma mark - btnAction
- (void)onSaveAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveBtnAction:)]) {
        [self.delegate saveBtnAction:sender];
    }
}

// 测量时间
- (void)showTimeRangeSelector:(TimeRangeType)rangeType {
    PopoverSelector *selector = [[PopoverSelector alloc] initSelectorWithFrameRangeType:CGRectMake(5, UISCREEN_height - 216, UISCREEN_width - 20, 216) RangeType:rangeType];
    
    [selector setTitle:[Utility dateToString:_curDate]];
    [selector setSelectDelegate:self];
    
    [selector show];
}

// 测量点
- (void)showTimeSlot {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showTimeSlot)]) {
        [self.delegate showTimeSlot];
    }
}

#pragma mark - popover selector method
- (void)itemSelected:(PopoverSelector*)selector SelectedItem:(NSString*)item {
    self.measureTime = item;
    UILabel *lab_time = [self viewWithTag:204];
    lab_time.text = item;
    UILabel *lab_slot = [self viewWithTag:205];
    NSDate *currentDate = [Utility zoneChange:item];
    lab_slot.text = [[[[Utility alloc]init]getTheTimeBucket:currentDate] objectForKey:@"selectStr"];
    _measureTimeSlot = [[[[Utility alloc]init]getTheTimeBucket:currentDate] objectForKey:@"selectIndex"];
    self.picTitleArr = [[[[Utility alloc]init]getTheTimeBucket:currentDate] objectForKey:@"pickerArr"];
}

// 监听textfield值改变
- (void)textChanged:(UITextField *)textField{
    [_ruler textChanged:self.stepperView.showTF];
}



@end

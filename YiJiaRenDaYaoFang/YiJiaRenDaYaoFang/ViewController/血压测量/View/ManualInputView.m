//
//  ManualInputView.m
//  JuShanTangYaoDian
//
//  Created by apple on 16/12/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "ManualInputView.h"

@implementation ManualInputView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}


- (void)configUI{
    //手动输入 页面
    UITableView *tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
    tableV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:tableV];
    _manualInputView = tableV;
    _manualInputView.delegate = self;
    _manualInputView.dataSource = self;
    _manualInputView.allowsSelection = NO;
    _manualInputView.scrollEnabled = NO;
    
    //添加手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.delegate = self;
    
    [self addGestureRecognizer:singleTap];
}
#pragma mark - 初始化

- (NSMutableArray *)arrayLabel
{
    if (nil == _arrayLabel) {
        _arrayLabel = [[NSMutableArray alloc] initWithObjects:@"高压：", @"低压：",@"心率：",@"时间：", nil];
    }
    
    return _arrayLabel;
}

- (NSMutableArray *)arrayImgView{
    if (nil == _arrayImgView) {
        _arrayImgView = [[NSMutableArray alloc]initWithObjects:@"icon_bph",@"icon_bpl",@"icon_hr",@"icon_clock", nil];
    }
    return _arrayImgView;
}

- (NSMutableArray *)arrayUnitLabel{
    if (nil == _arrayUnitLabel) {
        _arrayUnitLabel = [[NSMutableArray alloc]initWithObjects:@"mmHg",@"mmHg",@"  次/分", nil];
    }
    return _arrayUnitLabel;
}



#pragma mark -- UITabViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayLabel.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4) {
        return (108 + 34)/Proportion_height;
    }
    return 58/Proportion_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *customStrIdentity = @"customCellIdentity";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:customStrIdentity];
    if (nil == cell) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:nil options:nil];
        cell = [arr firstObject];
        
    }
    cell.inputTextField.tag = indexPath.row + 100;
    cell.inputTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    
    switch (indexPath.row) {
        case 0:
            if (0 == cell.inputTextField.text.length) {
                _highPressure = @"";
            }
            
            break;
            
        case 1:
            if (0 == cell.inputTextField.text.length) {
                _lowPressure = @"";
            }
            break;
        case 2:
            if (0 == cell.inputTextField.text.length) {
                _heartRate = @"";
            }
            break;
        default:
            break;
    }
    
    
    if (indexPath.row < 4) {
        cell.imgView.image = [UIImage imageNamed:self.arrayImgView[indexPath.row]];
        cell.titleLabel.text = self.arrayLabel[indexPath.row];
    }
    
    if (indexPath.row < 3) {
        cell.unitLabel.text = self.arrayUnitLabel[indexPath.row];
        cell.unitLabel.textColor = UIColorFromRGBA(0xbababa, 1.0);
    }else if(indexPath.row == 3){
        _curDate = [NSDate date];
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterMediumStyle];
        [_formatter setTimeStyle:NSDateFormatterShortStyle];
        [_formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *dateTime = [_formatter stringFromDate:_curDate];
        
        [cell.inputTextField mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(cell.mas_right).offset(-10);
            make.width.mas_equalTo(self.bounds.size.width/2);
        }];
        [cell.inputTextField layoutIfNeeded];
        
        
        if (0 == cell.inputTextField.text.length) {
            cell.inputTextField.text = dateTime;
            _checkDate = dateTime;
        }
        
        [cell.unitLabel removeFromSuperview];
    }
    
    if (indexPath.row == 4) {
        [cell.imgView removeFromSuperview];
        [cell.titleLabel removeFromSuperview];
        [cell.inputTextField removeFromSuperview];
        [cell.unitLabel removeFromSuperview];
        
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [saveBtn setTitle:@"保存记录" forState:UIControlStateNormal];
        saveBtn.contentMode=UIViewContentModeScaleAspectFit;
        saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
        [saveBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(onSaveAction:) forControlEvents:UIControlEventTouchUpInside];
        saveBtn.tag = 300;
        
        [cell addSubview:saveBtn];
        [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(123);
            make.height.mas_equalTo(34);
            make.top.equalTo(cell.mas_top).offset(54/Proportion_height);
            make.left.equalTo(cell.mas_left).offset(self.bounds.size.width/2.0-123/2.0);
        }];
        [saveBtn layoutIfNeeded];
    }
    
    return cell;
}

- (void)onSaveAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveBtnAction:)]) {
        [self.delegate saveBtnAction:sender];
    }
}


#pragma mark -- textfieldDelegate

- (void)textChanged:(NSNotification *)notification
{
    //获得textfield
    UITextField *textField = notification.object;
    
    if (textField.tag == 100 || textField.tag == 101 || textField.tag == 102) {
        
        //获取改变了的textfield对应的NSIndexPath
        //获取到对应的NSIndexPath就可以设置对应的数据源了
        CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:self.manualInputView];
        
        NSIndexPath *indexPath = [self.manualInputView indexPathForRowAtPoint:point];
        
        switch (indexPath.row) {
            case 0:
                if (0 < textField.text.length) {
                    _highPressure = textField.text;
                    if ([textField.text intValue] > 280) {
                        SHOW_ALERT(@"输入的血压值不能超过280");
                        textField.text = @"";
                    }
                }
                break;
                
            case 1:
                if (0 < textField.text.length) {
                    _lowPressure = textField.text;
                    if ([textField.text intValue] > 280) {
                        SHOW_ALERT(@"输入的血压值不能超过280");
                        textField.text = @"";
                    }
                }
                break;
            case 2:{
                if (0 < textField.text.length) {
                    _heartRate = textField.text;
                    if ([textField.text intValue] > 160) {
                        textField.text = @"";
                        SHOW_ALERT(@"输入的心率值不能超过160");
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 100 || textField.tag == 101 || textField.tag == 102) {
        return [Utility validateNumber:string];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 103) {
        [(UITextField *)[self viewWithTag:100] resignFirstResponder];
        [(UITextField *)[self viewWithTag:101] resignFirstResponder];
        [(UITextField *)[self viewWithTag:102] resignFirstResponder];
        [self showTimeRangeSelector:YYYYMMDDHHMM];
        return NO;
    }
    _selector = nil;
    
    return YES;
}

- (void)showTimeRangeSelector:(TimeRangeType)rangeType{
    NSString *dateTime = [_formatter stringFromDate:_curDate];
    UITextField *textField = (UITextField *)[self viewWithTag:103];
    _selector = [[PopoverSelector alloc] initSelectorWithFrameRangeType:CGRectMake(5, self.bounds.size.height - 216, self.bounds.size.width - 20, 216) RangeType:rangeType];
    [_selector setTitle:dateTime];
    [_selector setTag:10000 + 1];
    [_selector setSelectDelegate:self];
    textField.inputView = _selector;
    
    [_selector show];
}


#pragma popover selector method
- (void)itemSelected:(PopoverSelector*)selector SelectedItem:(NSString*)item{
    UITextField *textField = (UITextField *)[self viewWithTag:103];
    [textField setText:item];
    _checkDate = item;
}


//键盘下落
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self endEditing:YES];
}

@end

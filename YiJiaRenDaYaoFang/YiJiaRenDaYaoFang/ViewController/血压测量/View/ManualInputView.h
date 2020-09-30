//
//  ManualInputView.h
//  JuShanTangYaoDian
//
//  Created by apple on 16/12/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"
#import "PopoverSelector.h"


@protocol ManualInputViewDelegate <NSObject>

- (void)saveBtnAction:(UIButton *)sender;

@end


@interface ManualInputView : UIView<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic)UITableView        *manualInputView;
@property (nonatomic, strong)NSMutableArray     *arrayLabel;
@property (nonatomic, strong)NSMutableArray     *arrayImgView;
@property (nonatomic, strong)NSMutableArray     *arrayUnitLabel;
@property (nonatomic, strong)NSMutableData      *dataRet;

@property (nonatomic, retain) NSDate * curDate;
@property (nonatomic, retain) NSDateFormatter * formatter;
@property (nonatomic, strong)PopoverSelector *selector;

//输入的血压值
@property (nonatomic, copy)NSString *highPressure;
@property (nonatomic, copy)NSString *lowPressure;
@property (nonatomic, copy)NSString *heartRate;
@property (nonatomic, copy)NSString *checkDate;

@property (nonatomic, strong)UIButton *saveBtn;

@property (nonatomic, weak)id<ManualInputViewDelegate> delegate;




@end

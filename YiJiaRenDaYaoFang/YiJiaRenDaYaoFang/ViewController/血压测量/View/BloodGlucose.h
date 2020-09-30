//
//  BloodGlucose.h
//  JuShanTangYaoDian
//
//  Created by apple on 16/12/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXHRrettyRuler.h"
#import "PopoverSelector.h"
#import "MFStepperView.h"

@protocol BloodGlucoseDelegate <NSObject>

- (void)saveBtnAction:(UIButton *)sender;
- (void)showTimeSlot;

@end


@interface BloodGlucose : UIView<UITableViewDelegate,UITableViewDataSource,TXHRrettyRulerDelegate>{
    TXHRrettyRuler *_ruler;
}

@property (nonatomic, weak)id<BloodGlucoseDelegate> delegate;

@property (nonatomic, strong)NSArray *arr;
@property (nonatomic, strong)UITableView *tableV;
@property (nonatomic, strong)MFStepperView *stepperView;
@property (nonatomic, strong)UILabel *tipLab;
@property (nonatomic, strong)UIButton *saveBtn;//保存记录

@property (nonatomic, copy)NSString *measureTime;//测量时间
@property (nonatomic, copy)NSString *measureTimeSlot;//测量点
@property (nonatomic, strong)NSMutableArray *picTitleArr;


//时间选择器
@property (nonatomic, retain) NSDate * curDate;
@property (nonatomic, strong) PopoverSelector *selector;



@end

//
//  TimeRangePicker.h
//  ZJTApps
//
//  Created by dumbbellyang on 8/7/15.
//  Copyright (c) 2015 Magic Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeRangePicker : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>{
    int             componentsCount;
    
    NSString        *dateSeparator;
    NSString        *timeSeparator;
    NSString        *dateTimeSeparator;
    NSString        *rangeSeparator;
    
    NSInteger       textAlignment;
    NSInteger       fontSize;
    
    BOOL            isShowChinese;
    
    BOOL            isShowYear;
    int             yearComponentIdx;
    NSMutableArray  *yearData;
    
    BOOL            isShowMonth;
    int             monthComponentIdx;
    NSMutableArray  *monthData;
    
    BOOL            isShowDay;
    int             dayComponentIdx;
    NSMutableArray  *dayData;
    //如果开始月和结束月不是同一个，天的数值可能不同
    NSMutableArray  *toDayData;
    
    BOOL            isShowHour;
    int             hourComponentIdx;
    NSMutableArray  *hourData;
    
    BOOL            isShowMinute;
    int             minuteComponentIdx;
    NSMutableArray  *minuteData;
    
    BOOL            isShowSecond;
    int             secondComponentIdx;
    NSMutableArray  *secondData;
    
    int             currentYear;
    int             currentMonth;
    int             currentDay;
    int             currentHour;
    int             currentMinute;
    int             currentSecond;
    
    int             selectedYearFrom;
    int             selectedMonthFrom;
    int             selectedDayFrom;
    int             selectedHourFrom;
    int             selectedMinuteFrom;
    int             selectedSecondFrom;
    
    int             selectedYearTo;
    int             selectedMonthTo;
    int             selectedDayTo;
    int             selectedHourTo;
    int             selectedMinuteTo;
    int             selectedSecondTo;
    
    int             startYear;
    int             endYear;
    
    int             rangeSeparatorIdx;
}

@property (nonatomic, readwrite) int             componentsCount;

@property (nonatomic, retain)    NSString        *dateSeparator;
@property (nonatomic, retain)    NSString        *timeSeparator;
@property (nonatomic, retain)    NSString        *dateTimeSeparator;
@property (nonatomic, retain)    NSString        *rangeSeparator;

@property (nonatomic, readwrite) NSInteger       textAlignment;
@property (nonatomic, readwrite) NSInteger       fontSize;

@property (nonatomic, readwrite) BOOL            isShowChinese;

@property (nonatomic, readwrite) int             currentYear;
@property (nonatomic, readwrite) int             currentMonth;
@property (nonatomic, readwrite) int             currentDay;
@property (nonatomic, readwrite) int             currentHour;
@property (nonatomic, readwrite) int             currentMinute;
@property (nonatomic, readwrite) int             currentSecond;

@property (nonatomic, readwrite) int             selectedYearFrom;
@property (nonatomic, readwrite) int             selectedMonthFrom;
@property (nonatomic, readwrite) int             selectedDayFrom;
@property (nonatomic, readwrite) int             selectedHourFrom;
@property (nonatomic, readwrite) int             selectedMinuteFrom;
@property (nonatomic, readwrite) int             selectedSecondFrom;
@property (nonatomic, readwrite) int             selectedYearTo;
@property (nonatomic, readwrite) int             selectedMonthTo;
@property (nonatomic, readwrite) int             selectedDayTo;
@property (nonatomic, readwrite) int             selectedHourTo;
@property (nonatomic, readwrite) int             selectedMinuteTo;
@property (nonatomic, readwrite) int             selectedSecondTo;

@property (nonatomic, readwrite) BOOL            isShowYear;
@property (nonatomic, readwrite) int             yearComponentIdx;
@property (nonatomic, retain)    NSMutableArray  *yearData;

@property (nonatomic, readwrite) BOOL            isShowMonth;
@property (nonatomic, readwrite) int             monthComponentIdx;
@property (nonatomic, retain)    NSMutableArray  *monthData;

@property (nonatomic, readwrite) BOOL            isShowDay;
@property (nonatomic, readwrite) int             dayComponentIdx;
@property (nonatomic, retain)    NSMutableArray  *dayData;
@property (nonatomic, retain)    NSMutableArray  *toDayData;

@property (nonatomic, readwrite) BOOL            isShowHour;
@property (nonatomic, readwrite) int             hourComponentIdx;
@property (nonatomic, retain)    NSMutableArray  *hourData;

@property (nonatomic, readwrite) BOOL            isShowMinute;
@property (nonatomic, readwrite) int             minuteComponentIdx;
@property (nonatomic, retain)    NSMutableArray  *minuteData;

@property (nonatomic, readwrite) BOOL            isShowSecond;
@property (nonatomic, readwrite) int             secondComponentIdx;
@property (nonatomic, retain)    NSMutableArray  *secondData;

@property (nonatomic, retain)    UIView          *showView;

@property (nonatomic, readwrite) int             startYear;
@property (nonatomic, readwrite) int             endYear;
@property (nonatomic, readwrite) int             rangeSeparatorIdx;

- (NSString*)getCurrentLanguage;
- (NSString*)getCurrentLocale;

- (void)initCurrentDateData;
- (void)selectedCurrentDate;
- (void)clearAllComponents;
- (void)show:(UIView*)view;
- (void)hide;

- (NSInteger)findDaysInYear:(NSInteger)curYear;
- (NSInteger)findDaysInMonth:(NSInteger) monthNum CurYear:(NSInteger)curYear;
- (void)resetDayData:(NSInteger)totalDays;
- (NSInteger)getDatePartFromDate:(NSDate*)curDate PartFormat:(NSString*)partFormat;
- (NSInteger)getYearFromDate:(NSDate*)curDate;
- (NSInteger)getMonthFromDate:(NSDate*)curDate;
- (NSInteger)getDayFromDate:(NSDate*)curDate;
- (NSInteger)getHourFromDate:(NSDate*)curDate;
- (NSInteger)getMinuteFromDate:(NSDate*)curDate;
- (NSInteger)getSecondFromDate:(NSDate*)curDate;

@end

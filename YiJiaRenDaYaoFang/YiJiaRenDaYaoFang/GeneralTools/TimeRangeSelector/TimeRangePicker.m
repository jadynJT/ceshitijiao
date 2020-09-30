//
//  TimeRangePicker.m
//  ZJTApps
//
//  Created by dumbbellyang on 8/7/15.
//  Copyright (c) 2015 Magic Studio. All rights reserved.
//

#import "TimeRangePicker.h"

@implementation TimeRangePicker

@synthesize      componentsCount;

@synthesize      dateSeparator;
@synthesize      timeSeparator;
@synthesize      dateTimeSeparator;
@synthesize      rangeSeparator;

@synthesize      textAlignment;
@synthesize      fontSize;

@synthesize      isShowChinese;

@synthesize      currentYear;
@synthesize      currentMonth;
@synthesize      currentDay;
@synthesize      currentHour;
@synthesize      currentMinute;
@synthesize      currentSecond;

@synthesize      selectedYearFrom;
@synthesize      selectedMonthFrom;
@synthesize      selectedDayFrom;
@synthesize      selectedHourFrom;
@synthesize      selectedMinuteFrom;
@synthesize      selectedSecondFrom;

@synthesize      selectedYearTo;
@synthesize      selectedMonthTo;
@synthesize      selectedDayTo;
@synthesize      selectedHourTo;
@synthesize      selectedMinuteTo;
@synthesize      selectedSecondTo;

@synthesize      isShowYear;
@synthesize      yearComponentIdx;
@synthesize      yearData;

@synthesize      isShowMonth;
@synthesize      monthComponentIdx;
@synthesize      monthData;

@synthesize      isShowDay;
@synthesize      dayComponentIdx;
@synthesize      dayData;
@synthesize      toDayData;

@synthesize      isShowHour;
@synthesize      hourComponentIdx;
@synthesize      hourData;

@synthesize      isShowMinute;
@synthesize      minuteComponentIdx;
@synthesize      minuteData;

@synthesize      isShowSecond;
@synthesize      secondComponentIdx;
@synthesize      secondData;

@synthesize      showView;
@synthesize      startYear;
@synthesize      endYear;
@synthesize      rangeSeparatorIdx;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setDateSeparator:@"-"];
        [self setTimeSeparator:@":"];
        [self setDateTimeSeparator:@" "];
        //[self setRangeSeparator:@"~"];
        
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setFontSize:16];
        
        NSString *lang = [self getCurrentLanguage];
        NSString *loca = [self getCurrentLocale];
        
        //NSLog(@"Current Lang:%@,current Locale:%@",lang,loca);
        
        if([lang isEqualToString:@"zh-Hans"] && [loca hasPrefix:@"中文"]){
            isShowChinese = YES;
        }
        else if ([lang isEqualToString:@"en"] && [loca hasPrefix:@"Chinese"]){
            isShowChinese = YES;
        }
        else {
            isShowChinese = NO;
        }
        
        [self setStartYear:1949];
        [self setEndYear:2050];
    }
    
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration{
    
}

#pragma mark Date Operation methods
- (NSString*)getCurrentLanguage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *curLanguage = [languages objectAtIndex:0];
    
    return curLanguage;
}

- (NSString*)getCurrentLocale{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *curLocale = [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
    
    return curLocale;
}

- (NSInteger)findDaysInYear:(NSInteger)curYear{
    NSString *dateFrom = [NSString stringWithFormat:@"%ld/01/01",(long)curYear];
    NSString *dateTo = [NSString stringWithFormat:@"%ld/12/31",(long)curYear];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy/MM/dd"];
    NSDate *startDate = [df dateFromString:dateFrom];
    NSDate *endDate = [df dateFromString:dateTo];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit ;
    NSDateComponents *componentsDay = [gregorian components:unitFlags fromDate:startDate toDate:endDate options:0];
    NSInteger days = [componentsDay day] + 1;
    
    if (days != 365 && days != 366) {
        return 366;
    }
    
    return days;
}

- (NSInteger)findDaysInMonth:(NSInteger) monthNum CurYear:(NSInteger)curYear{
    NSInteger days = 30;
    
    switch (monthNum) {
        case 1:
            days = 31;
            break;
        case 2:
            if([self findDaysInYear:curYear] == 366){
                days = 29;
            }
            else {
                days = 28;
            }
            break;
        case 3:
            days = 31;
            break;
        case 4:
            days = 30;
            break;
        case 5:
            days = 31;
            break;
        case 6:
            days = 30;
            break;
        case 7:
            days = 31;
            break;
        case 8:
            days = 31;
            break;
        case 9:
            days = 30;
            break;
        case 10:
            days = 31;
            break;
        case 11:
            days = 30;
            break;
        case 12:
            days = 31;
            break;
        default:
            break;
    }
    
    return days;
}

- (void)resetDayData:(NSInteger)totalDays{
    dayData = [[NSMutableArray alloc ]initWithCapacity:totalDays];
    for(int i = 1;i <= totalDays;i ++){
        if (isShowChinese) {
            [dayData addObject:[NSString stringWithFormat:@"%d日",i]];
        }
        else{
            [dayData addObject:[NSString stringWithFormat:@"%02d",i]];
        }
    }
}

- (void)resetToDayData:(NSInteger)totalDays{
    toDayData = [[NSMutableArray alloc ]initWithCapacity:totalDays];
    for(int i = 1;i <= totalDays;i ++){
        if (isShowChinese) {
            [toDayData addObject:[NSString stringWithFormat:@"%d日",i]];
        }
        else{
            [toDayData addObject:[NSString stringWithFormat:@"%02d",i]];
        }
    }
}

- (void)initCurrentDateData{
    NSDate *now = [NSDate date];
    
    if (showView != nil) {
        if ([showView isKindOfClass:[UITextField class]]) {
            [(UITextField*)showView setText:[Utility dateToString:now]];
        }
        else if ([showView isKindOfClass:[UILabel class]]){
            [(UILabel*)showView setText:[Utility dateToString:now]];
        }
        else {
            [[Utility dateToString:now] drawAtPoint:showView.frame.origin withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}];
        }
    }

    currentYear = (int)[self getYearFromDate:now];
    selectedYearFrom = currentYear;
    currentMonth = (int)[self getMonthFromDate:now];
    selectedMonthFrom = currentMonth;
    currentDay = (int)[self getDayFromDate:now];
    selectedDayFrom = currentDay;
    currentHour = (int)[self getHourFromDate:now];
    selectedHourFrom = currentHour;
    currentMinute = (int)[self getMinuteFromDate:now];
    selectedMinuteFrom = currentMinute;
    currentSecond = (int)[self getSecondFromDate:now];
    selectedSecondFrom = currentSecond;
    
    selectedYearTo = selectedYearFrom;
    selectedMonthTo = selectedMonthFrom;
    selectedDayTo =selectedDayFrom;
    selectedHourTo = selectedHourFrom;
    selectedMinuteTo = selectedMinuteFrom;
    selectedSecondTo = selectedSecondFrom;
    
    if (yearData == nil){
        yearData = [[NSMutableArray alloc] initWithCapacity:9999];
        for(int i = [self startYear];i <= [self endYear];i ++){
            if (isShowChinese) {
                [yearData addObject:[NSString stringWithFormat:@"%d年", i]];
            }
            else{
                [yearData addObject:[NSString stringWithFormat:@"%d", i]];
            }
        }
    }
    
    if (monthData == nil) {
        monthData = [[NSMutableArray alloc] initWithCapacity:12];
        for(int i = 1;i <= 12;i ++){
            if (isShowChinese) {
                [monthData addObject:[NSString stringWithFormat:@"%d月",i]];
            }
            else {
                [monthData addObject:[NSString stringWithFormat:@"%02d",i]];
            }
        }
    }
    
    if (dayData == nil) {
        NSInteger totalDays = [self findDaysInMonth:currentMonth CurYear:currentYear];
        [self resetDayData:totalDays];
    }
    if (toDayData == nil) {
        NSInteger totalDays = [self findDaysInMonth:currentMonth CurYear:currentYear];
        [self resetToDayData:totalDays];
    }
    
    if (hourData == nil) {
        hourData = [[NSMutableArray alloc] initWithCapacity:24];
        for(int i = 0;i <= 23;i ++){
            if (isShowChinese){
                [hourData addObject:[NSString stringWithFormat:@"%d时",i]];
            }
            else {
                [hourData addObject:[NSString stringWithFormat:@"%02d",i]];
            }
        }
    }
    
    if (minuteData == nil) {
        minuteData = [[NSMutableArray alloc] initWithCapacity:60];
        for(int i = 0;i <= 59;i ++){
            if (isShowChinese) {
                [minuteData addObject:[NSString stringWithFormat:@"%d分",i]];
            }
            else{
                [minuteData addObject:[NSString stringWithFormat:@"%02d",i]];
            }
        }
    }
    
    if (secondData == nil) {
        secondData = [[NSMutableArray alloc] initWithCapacity:60];
        for(int i = 0;i <= 59;i ++){
            if (isShowChinese) {
                [secondData addObject:[NSString stringWithFormat:@"%d秒",i]];
            }
            else{
                [secondData addObject:[NSString stringWithFormat:@"%02d",i]];
            }
        }
    }
}

- (NSInteger)getDatePartFromDate:(NSDate*)curDate PartFormat:(NSString*)partFormat{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:partFormat];
    NSInteger curPart = [[df stringFromDate:curDate] intValue];
    
    return curPart;
}

- (NSInteger)getYearFromDate:(NSDate*)curDate{
    return [self getDatePartFromDate:curDate PartFormat:@"yyyy"];
}

- (NSInteger)getMonthFromDate:(NSDate*)curDate{
    return [self getDatePartFromDate:curDate PartFormat:@"MM"];
}

- (NSInteger)getDayFromDate:(NSDate*)curDate{
    return [self getDatePartFromDate:curDate PartFormat:@"dd"];
}

- (NSInteger)getHourFromDate:(NSDate*)curDate{
    return [self getDatePartFromDate:curDate PartFormat:@"HH"];
}

- (NSInteger)getMinuteFromDate:(NSDate*)curDate{
    return [self getDatePartFromDate:curDate PartFormat:@"mm"];
}

- (NSInteger)getSecondFromDate:(NSDate*)curDate{
    return [self getDatePartFromDate:curDate PartFormat:@"ss"];
}

- (void)selectedCurrentDate{
    if (isShowYear) {
        [self selectRow:(currentYear - [self startYear]) inComponent:yearComponentIdx animated:NO];
    }
    if (isShowMonth) {
        [self selectRow:(currentMonth - 1) inComponent:monthComponentIdx animated:NO];
    }
    if (isShowDay){
        [self selectRow:(currentDay - 1) inComponent:dayComponentIdx animated:NO];
    }
    if (isShowHour) {
        [self selectRow:currentHour inComponent:hourComponentIdx animated:NO];
    }
    if (isShowMinute) {
        [self selectRow:currentMinute inComponent:minuteComponentIdx animated:NO];
    }
    if (isShowSecond) {
        [self selectRow:currentSecond inComponent:secondComponentIdx animated:NO];
    }
}

- (void)show:(UIView*)view{
    BOOL isFirstShow = NO;
    if ([self yearData] == nil){
        [self initCurrentDateData];
        isFirstShow = YES;
    }
    
    [self setShowsSelectionIndicator:YES];
    [self setUserInteractionEnabled:YES];
    [self setDataSource:self];
    [self setDelegate:self];
    
    if (isFirstShow){
        [self selectedCurrentDate];
    }
    
    [view addSubview:self];
    [self.superview bringSubviewToFront:self];
}

- (void)hide{
    [self removeFromSuperview];
}

- (void)clearAllComponents{
    yearComponentIdx = -1;
    monthComponentIdx = -1;
    dayComponentIdx = -1;
    hourComponentIdx = -1;
    minuteComponentIdx = -1;
    secondComponentIdx = -1;
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger count = 0;
    [self clearAllComponents];
    
    if (isShowYear) {
        yearComponentIdx = (int)count ++;
    }
    if (isShowMonth) {
        monthComponentIdx = (int)count ++;
    }
    
    if (isShowDay) {
        dayComponentIdx = (int)count ++;
    }
    
    if (isShowHour) {
        hourComponentIdx = (int)count ++;
    }
    
    if (isShowMinute) {
        minuteComponentIdx = (int)count ++;
    }
    
    if (isShowSecond) {
        secondComponentIdx = (int)count ++;
    }
    
    //From  ~  To
    componentsCount = (int)count;
    
    rangeSeparatorIdx = (int)count;
    
//    NSLog(@"components count: %d ,separator:%d",componentsCount, rangeSeparatorIdx);
    
    return componentsCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger rowsCount = 0;
    if (component == rangeSeparatorIdx){
        rowsCount = 1;
    }
    else if (component % (rangeSeparatorIdx + 1) == yearComponentIdx){
        rowsCount = [yearData count];
    }
    else if (component % (rangeSeparatorIdx + 1) == monthComponentIdx ){
        rowsCount = [monthData count];
    }
    else if (component == dayComponentIdx){
        rowsCount = [dayData count];
    }
    else if (component % (rangeSeparatorIdx + 1) == dayComponentIdx){
        rowsCount = [toDayData count];
    }
    else if (component % (rangeSeparatorIdx + 1) == hourComponentIdx){
        rowsCount = [hourData count];
    }
    else if (component % (rangeSeparatorIdx + 1) == minuteComponentIdx){
        rowsCount = [minuteData count];
    }
    else if (component % (rangeSeparatorIdx + 1) == secondComponentIdx){
        rowsCount = [secondData count];
    }
    
    //NSLog(@" component %d rowscount %d", component, rowsCount);
    
    return rowsCount;
}

#pragma mark Picker Delegate Methods
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(6.0f, 0.0f,
                                                               [pickerView rowSizeForComponent:component].width - 6,
                                                               [pickerView rowSizeForComponent:component].height)];
    [label setFont:[UIFont boldSystemFontOfSize:fontSize]];
    
    if (component == rangeSeparatorIdx ){
        [label setText:rangeSeparator];
    }
    else if (component % (rangeSeparatorIdx + 1) == yearComponentIdx){
        [label setText:[self.yearData objectAtIndex:row]];
        
        if (row == currentYear - 1) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    else if (component % (rangeSeparatorIdx + 1) == monthComponentIdx){
        [label setText:[self.monthData objectAtIndex:row]];
        
        if (row == currentMonth - 1) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    else if (component == dayComponentIdx){
        [label setText:[self.dayData objectAtIndex:row]];
        
        if (row == currentDay - 1) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    else if (component == dayComponentIdx + rangeSeparatorIdx + 1){
        [label setText:[self.toDayData objectAtIndex:row]];
        
        if (row == currentDay - 1) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    else if (component % (rangeSeparatorIdx + 1) == hourComponentIdx){
        [label setText:[self.hourData objectAtIndex:row]];
        
        if (row == currentHour) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    else if (component % (rangeSeparatorIdx + 1) == minuteComponentIdx){
        [label setText:[self.minuteData objectAtIndex:row]];
        
        if (row == currentMinute) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    else if (component % (rangeSeparatorIdx + 1) == secondComponentIdx){
        [label setText:[self.secondData objectAtIndex:row]];
        
        if (row == currentSecond) {
            [label setTextColor:[UIColor blueColor]];
        }
    }
    
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setTextAlignment:textAlignment];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == yearComponentIdx){
        selectedYearFrom = [[[self yearData] objectAtIndex:row] intValue];
        
        if (isShowMonth && isShowDay) {
            NSInteger selectedMonth = [pickerView selectedRowInComponent:monthComponentIdx] + 1;
            NSInteger intDays = [self findDaysInMonth:selectedMonth CurYear:selectedYearFrom];
            
            [self resetDayData:intDays];
            [pickerView reloadComponent:dayComponentIdx];
        }
    }
    else if (component == monthComponentIdx){
        selectedMonthFrom = (int)row + 1;
        if (isShowDay) {
            NSInteger intDays = [self findDaysInMonth:selectedMonthFrom CurYear:selectedYearFrom];
           
            [self resetDayData:intDays];
            [pickerView reloadComponent:dayComponentIdx];
        }
    }

    else if (component == dayComponentIdx){
        selectedDayFrom = (int)row + 1;
        if ((isShowDay) && (component != dayComponentIdx)) {
            [pickerView selectRow:row inComponent:dayComponentIdx  animated:YES];
        }
    }

    else if (component == hourComponentIdx){
        selectedHourFrom = (int)row;
    }

    else if (component == minuteComponentIdx){
        selectedMinuteFrom = (int)row;
    }

    else if (component == secondComponentIdx){
        selectedSecondFrom = (int)row;
    }
    
    NSString *selectedFrom = @"";
    if (isShowYear) {
        selectedFrom = [NSString stringWithFormat:@"%d",selectedYearFrom];

    }
    if (isShowMonth) {
        selectedFrom = [[selectedFrom stringByAppendingString:(isShowYear ? dateSeparator : @"")]
                            stringByAppendingString:[NSString stringWithFormat:@"%02d",selectedMonthFrom]];
    }
    if (isShowDay) {
        selectedFrom = [[selectedFrom stringByAppendingString: (isShowMonth ? dateSeparator : @"")]
                            stringByAppendingString:[NSString stringWithFormat:@"%02d",selectedDayFrom]];
    }
    if (isShowHour) {
        selectedFrom = [[selectedFrom stringByAppendingString:(isShowDay ? dateTimeSeparator : @"")]
                            stringByAppendingString:[NSString stringWithFormat:@"%02d",selectedHourFrom]];

        //NSLog(@" selected from %@ to %@",selectedFrom,selectedTo);
    }
    if (isShowMinute) {
        selectedFrom = [[selectedFrom stringByAppendingString:(isShowHour ? timeSeparator : @"")]
                            stringByAppendingString:[NSString stringWithFormat:@"%02d",selectedMinuteFrom]];
    }
    if (isShowSecond) {
        selectedFrom = [[selectedFrom stringByAppendingString:timeSeparator]
                            stringByAppendingString:[NSString stringWithFormat:@"%02d",selectedSecondFrom]];
    }
    
    if (showView != nil) {
        if ([showView isKindOfClass:[UITextField class]]) {
            [(UITextField*)showView setText:[NSString stringWithFormat:@"%@",selectedFrom]];
        }
        else if ([showView isKindOfClass:[UILabel class]]){
            [(UILabel*)showView setText:[NSString stringWithFormat:@"%@",selectedFrom]];
        }
        else {
            [[NSString stringWithFormat:@"%@",selectedFrom] drawAtPoint:showView.frame.origin withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]}];
        }
    }	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    CGFloat curWidth = 60.0f;
    if (component == rangeSeparatorIdx){
        curWidth = 30.0f;
    }
    else if (component % (rangeSeparatorIdx + 1) == yearComponentIdx){
        if (componentsCount == 2) {
            curWidth = 120.0f;
        }
        else {
            curWidth = 64.0f;
        }
    }
    else if (component % (rangeSeparatorIdx + 1) == monthComponentIdx){
        if (componentsCount == 2) {
            curWidth = 80.0f;
        }
        else if (isShowChinese){
            curWidth = 60.0f;
        }
        else {
            curWidth = 36.0f;
        }
    }
    else if (component % (rangeSeparatorIdx + 1) == dayComponentIdx ||
             component % (rangeSeparatorIdx + 1) == hourComponentIdx ||
             component % (rangeSeparatorIdx + 1) == minuteComponentIdx ||
             component % (rangeSeparatorIdx + 1) == secondComponentIdx){
        curWidth = 36.0f;
    }
    
    return curWidth;
}

@end

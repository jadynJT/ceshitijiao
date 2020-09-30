//
//  Utility.m
//  YiJiaRenDaYaoFang
//
//  Created by admin on 16/4/28.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "Utility.h"
#import "MeasurePageViewController.h"
#import "SearchViewController.h"
#import "MemerShipViewController.h"
#import "SlowDiseaseMemberViewController.h"

@implementation Utility

+ (BOOL)isIPhone4
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 480.f;
}

+ (BOOL)isIPhone5
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 568.f;
}

+ (BOOL)isIPhone6
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 667.f;
}

+ (BOOL)isIPhone6Plus
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 736.f;
}

+ (NSString *)lanchImageInch:(NSString *)keySize {
    NSDictionary * dict = @{@"320x480" : @"LaunchImage-700@2x",
                            @"320x568" : @"LaunchImage-700-568h@2x",
                            @"375x667" : @"LaunchImage-800-667h@2x",
                            @"414x736" : @"LaunchImage-800-Portrait-736h@3x",
                            @"375x812" : @"LaunchImage-1100-Portrait-2436h",
                            @"414x896" : @"LaunchImage-1200-Portrait-2688h"};
    
    return dict[keySize];
}

+ (void)gotoNextVC:(UIViewController *)vc fromViewController:(UIViewController *)viewCtr{
    
    [viewCtr.navigationController pushViewController:vc animated:YES];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [viewCtr.navigationItem setBackBarButtonItem:backBtn];
}

+ (BOOL)isBlankString:(NSString *)string {
    
    if (string == nil || string == NULL || [string isEqual:@""]) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    return NO;
}

//超时处理
- (void)onTimeOutAction:(QqcWebView *)webview {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"fail" withExtension:@"html"];
        
        [webview loadRequestWithString:url.absoluteString];
    });
}

//加载失败处理
- (void)catchError:(NSError *)error webView:(QqcWebView *)webview {
    if ([error code] == -999) {
        return;
    }
    
    if (error.code == -22) {
        [self onTimeOutAction:webview];
    }else if (error.code == -1001){
        [self onTimeOutAction:webview];
    }else if (error.code == -1005){
        [self onTimeOutAction:webview];
    }else if (error.code == -1009){
        [self onTimeOutAction:webview];
    }
    
}

// 正则判断手机号码地址格式
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            SHOW_ALERT(@"请输入数字");
            res = NO;
            break;
        }
        
        i++;
    }
    return res;
}

//将yyyy-MM-dd HH:mm格式时间转换成时间戳
+ (long)changeTimeToTimeSp:(NSString *)timeStr
{
    long time;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *fromdate=[format dateFromString:timeStr];
    time= (long)[fromdate timeIntervalSince1970];
    NSLog(@"%ld",time);
    return time;
}

//将时间戳转换成NSDate,不知道是哪国时间
+ (NSDate *)changeSpToTime:(NSString*)spStr
{
    //    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[spStr intValue]];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormat dateFromString:spStr];
    return date;
}

//将时间戳转换成NSDate,加上时区偏移。这个转换之后是北京时间
+ (NSDate*)zoneChange:(NSString*)spString
{
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    fmt.timeZone = timeZone;
    NSDateFormatter *dstFmt = [[NSDateFormatter alloc]init];
    dstFmt.dateFormat = @"yyyy-MM-dd HH:mm";
    dstFmt.timeZone = timeZone;
    NSDate *srcDate = [fmt dateFromString:spString];
    
    NSLog(@"srcDate---%@",srcDate);
    return srcDate;
}

//将NSDate按yyyy-MM-dd HH:mm 格式时间输出
+ (NSString*)dateToString:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString* string = [dateFormat stringFromDate:date];
    NSLog(@"%@",string);
    return string;
}

//获取当前系统的yyyy-MM-dd HH:mm 格式时间
+ (NSString *)getTime
{
    NSDate *fromdate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString* string = [dateFormat stringFromDate:fromdate];
    return string;
}

//将时间点转化成日历形式
- (NSDate *)getCustomDateWithHour:(NSInteger)hour currentDate:(NSDate *)currentDate
{
    //获取当前时间
    NSDate * destinationDateNow = currentDate;
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:unitFlags fromDate:destinationDateNow];
    
    //设置当前的时间点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    //    NSLog(@"resultCalendar---%@",[resultCalendar dateFromComponents:resultComps]);
    return [resultCalendar dateFromComponents:resultComps];
}

//获取时间段
- (NSDictionary *)getTheTimeBucket:(NSDate *)currentDate
{
    currentDate = [self getNowDateFromatAnDate:currentDate];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    if ([currentDate compare:[self getCustomDateWithHour:0 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:6 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"睡前",@"凌晨",@"早餐前", nil];
        return @{@"selectStr":@"凌晨",@"selectIndex":[NSNumber numberWithInteger:1],@"pickerArr":arr};
    }
    else if ([currentDate compare:[self getCustomDateWithHour:6 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"凌晨",@"早餐前",@"早餐后", nil];
        return @{@"selectStr":@"早餐前",@"selectIndex":[NSNumber numberWithInteger:2],@"pickerArr":arr};
    }
    else if ([currentDate compare:[self getCustomDateWithHour:9 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:11 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"早餐前",@"早餐后",@"午餐前", nil];
        return @{@"selectStr":@"早餐后",@"selectIndex":[NSNumber numberWithInteger:3],@"pickerArr":arr};
    }
    else if ([currentDate compare:[self getCustomDateWithHour:11 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:13 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"早餐后",@"午餐前",@"午餐后", nil];
        return @{@"selectStr":@"午餐前",@"selectIndex":[NSNumber numberWithInteger:4],@"pickerArr":arr};
    }
    else if ([currentDate compare:[self getCustomDateWithHour:13 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:17 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"午餐前",@"午餐后",@"晚餐前", nil];
        return @{@"selectStr":@"午餐后",@"selectIndex":[NSNumber numberWithInteger:5],@"pickerArr":arr};
    }
    else if ([currentDate compare:[self getCustomDateWithHour:17 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:19 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"午餐后",@"晚餐前",@"睡前", nil];
        return @{@"selectStr":@"晚餐前",@"selectIndex":[NSNumber numberWithInteger:6],@"pickerArr":arr};
    }
    else if ([currentDate compare:[self getCustomDateWithHour:19 currentDate:currentDate]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:22 currentDate:currentDate]] == NSOrderedAscending)
    {
        arr = [NSMutableArray arrayWithObjects:@"晚餐前",@"晚餐后",@"睡前", nil];
        return @{@"selectStr":@"晚餐后",@"selectIndex":[NSNumber numberWithInteger:7],@"pickerArr":arr};
    }
    
    arr = [NSMutableArray arrayWithObjects:@"晚餐后",@"睡前",@"凌晨", nil];
    return @{@"selectStr":@"睡前",@"selectIndex":[NSNumber numberWithInteger:8],@"pickerArr":arr};
    
}


+ (NSInteger)getIndex:(NSString *)str{
    if ([str isEqualToString:@"凌晨"]) {
        return 1;
    }else if([str isEqualToString:@"早餐前"]){
        return 2;
    }else if([str isEqualToString:@"早餐后"]){
        return 3;
    }else if([str isEqualToString:@"午餐前"]){
        return 4;
    }else if([str isEqualToString:@"午餐后"]){
        return 5;
    }else if([str isEqualToString:@"晚餐前"]){
        return 6;
    }else if([str isEqualToString:@"晚餐后"]){
        return 7;
    }else if([str isEqualToString:@"睡前"]){
        return 8;
    }
    return NSNotFound;
}


#warning -------此处要将系统时间转换为格林治时间《忧伤的故事~》
//考虑时区，获取准备的系统时间方法
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone localTimeZone];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}


+ (NSDate *)getLocalDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

//改变textfield色值
+ (void)changeColor:(UITextField *)textField {
    NSString * changeStr = textField.text;
    if ([changeStr floatValue] < 4.5 && [changeStr floatValue] > 0) {
        textField.textColor = UIColorFromRGBA(0xfa6128, 0.8);
    }
    if ([changeStr floatValue] < 10.1 && [changeStr floatValue] >= 4.5) {
        //绿色
        textField.textColor = UIColorFromRGBA(0x1dd06a, 0.8);
    }
    
    if ([changeStr floatValue] < 33.3 && [changeStr floatValue] >= 10.1) {
        //紫色
        textField.textColor = UIColorFromRGBA(0xff9800, 0.8);
    }
}

+(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
}

+ (void)webViewJavascriptBridge:(id)bridge
                    handlerName:(NSString *)handlerName
             webViewJSCallBlock:(void(^)(id data, WVJBResponseCallback responseCallback))webViewJSCallBlock {
    
    WVJBHandler WVJBhandle = ^(id data, WVJBResponseCallback responseCallback) {
        webViewJSCallBlock ? webViewJSCallBlock(data,responseCallback) : nil;
    };
    
    [(WKWebViewJavascriptBridge *)bridge registerHandler:handlerName handler:WVJBhandle];
}

@end

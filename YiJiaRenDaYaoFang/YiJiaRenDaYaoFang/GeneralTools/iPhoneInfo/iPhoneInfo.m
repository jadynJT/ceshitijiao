//
//  iPhoneInfo.m
//  百城求职宝
//
//  Created by sunshine on 15/9/9.
//  Copyright (c) 2015年 sunshine. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "iPhoneInfo.h"
#import "KeychainItemUtil.h"

#define OpenSessionID @"OpenSessionID"
#define kUniqueIdentifier @"kUniqueIdentifier"
#define kUniqueIdentifierValue @"kUniqueIdentifierValue"

@implementation iPhoneInfo

//手机别名(用户定义的名称)
+ (NSString *)userPhoneName{
    return [[UIDevice currentDevice] name];
}

//设备名称
+ (NSString *)deviceName{
    return [[UIDevice currentDevice] systemName];
}

//手机系统版本
+ (NSString *)phoneVersion{
    return [[UIDevice currentDevice] systemVersion];
}

//手机型号
+ (NSString *)phoneModel{
    return [[UIDevice currentDevice] model];
}

//地方型号(国际化区域名称)
+ (NSString *)localPhoneModel{
    return [[UIDevice currentDevice] localizedModel];
}

//获得设备型号
+ (NSString *)deviceModel{
    NSString *deviceType = [self currentDeviceModel];
    NSArray *array = [deviceType componentsSeparatedByString:@" "];
    if(array.count >= 2){
        return [NSString stringWithFormat:@"%@%@",array[0],array[1]];
    }
    return deviceType;
}

//手机序列号IDFV(设备唯一标示符)
+ (NSString *)identifierNumber{
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

//获取手机UUID(唯一识别码)
+ (NSString *)getUUID
{// 先从UserDefault中查找、没有再从钥匙串中查找、都没有则生成
    NSString *openUUID = [[NSUserDefaults standardUserDefaults] objectForKey:OpenSessionID];
    if (openUUID == nil)
    {
        CFUUIDRef puuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault,puuid);
        NSString *udidStr = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
        openUUID = udidStr;

        NSString *uniqueKeyItem =  [KeychainItemUtil passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:kUniqueIdentifierValue];
        if (uniqueKeyItem == nil || [uniqueKeyItem length] == 0) {
            uniqueKeyItem = openUUID;
            [KeychainItemUtil  setPassword:openUUID forService:[[NSBundle mainBundle] bundleIdentifier] account:kUniqueIdentifierValue];
        }
        [[NSUserDefaults standardUserDefaults] setObject:uniqueKeyItem forKey:OpenSessionID];
        [[NSUserDefaults  standardUserDefaults] synchronize];
        openUUID = uniqueKeyItem;
    }
    return openUUID;
}

+ (NSString *)currentDeviceModel{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
}

@end

//
//  iPhoneInfo.h
//  百城求职宝
//
//  Created by sunshine on 15/9/9.
//  Copyright (c) 2015年 sunshine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iPhoneInfo : NSObject

+ (NSString *)identifierNumber;
+ (NSString *)userPhoneName;
+ (NSString *)deviceName;
+ (NSString *)phoneVersion;
+ (NSString *)phoneModel;
+ (NSString *)getUUID;
+ (NSString *)localPhoneModel;
+ (NSString *)deviceModel;

@end

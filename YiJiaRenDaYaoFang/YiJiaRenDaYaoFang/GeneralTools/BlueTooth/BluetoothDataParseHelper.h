//
//  BluetoothDataParseHelper.h
//  HeartRate
//
//  Created by qqc on 16/6/10.
//  Copyright © 2016年 Qqc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BluetoothDataParseHelper : NSObject

/**
 *  十六进制字符串转换为Byte数组的NSData类型
 *
 *  @param strHex 十六进制字符串
 *
 *  @return Byte数组的NSData类型
 */
+ (NSData *)hexStrToBytes:(NSString *)strHex;

/**
 *  根据给定的十六进制字符串求得CheckSum值
 *
 *  @param strHex 十六进制字符串
 *
 *  @return 求得的CheckSum值（所有数据的总和取低字节）
 */
+ (NSData *)getCheckSum:(NSString *)strHex;


@end

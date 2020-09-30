//
//  BluetoothDataParseHelper.m
//  HeartRate
//
//  Created by qqc on 16/6/10.
//  Copyright © 2016年 Qqc. All rights reserved.
//

#import "BluetoothDataParseHelper.h"

@implementation BluetoothDataParseHelper

+ (NSData *)hexStrToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

+ (NSData *)getCheckSum:(NSString *)byteStr{
    int length = (int)byteStr.length/2;
    NSData *data = [self hexStrToBytes:byteStr];
    Byte *bytes = (unsigned char *)[data bytes];
    Byte sum = 0;
    for (int i = 0; i<length; i++) {
        sum += bytes[i];
    }
    
    int checksum = sum;
    
    NSString *str = [NSString stringWithFormat:@"%@",[self ToHex:checksum]];
    return [self hexStrToBytes:str];
}

+ (NSString *)ToHex:(int)tmpid
{
    NSString *nLetterValue;
    NSString *str = @"";
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    //不够一个字节凑0
    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
}

@end

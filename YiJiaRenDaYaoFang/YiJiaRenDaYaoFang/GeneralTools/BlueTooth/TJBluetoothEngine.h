//
//  TJBluetoothEngine.h
//  HeartRate
//
//  Created by qqc on 16/6/10.
//  Copyright © 2016年 Qqc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothDataParseHelper.h"

typedef void(^devPowerOffBlock)(BOOL bIsPowerOff);
typedef void(^configCodeBlock)(NSData* dataConfigCode);
typedef void(^checkRetBlock)(NSData* dataCheckRet);
typedef void(^checkRetResultBlock)(NSData* dataCheckRetResult);
typedef void(^connectStateBlock)(NSString* connectState);


@interface TJBluetoothEngine : NSObject

+ (instancetype)shareTJBluetoothEngine;

@property(nonatomic, copy)NSString* strConnectState;
@property(nonatomic, copy)NSString* strBattery;

/**
 *  开始运行，成功启动后，会返回天际设备的 厂商码
 *
 *  @param block 回调
 */
- (void)launchWithBlock:(configCodeBlock)blockConfig autoCheckRet:(checkRetBlock)blockCheck devPowerOff:(devPowerOffBlock)blockPowerOff autoCheckRetResult:(checkRetResultBlock)blockCheckResult connectState:(connectStateBlock)connectState;

//停止运行
- (void)stop;

//检查
- (void)checkWithRet:(checkRetBlock)blockCheck checkWithRetResult:(checkRetResultBlock)blockCheckResult connectState:(connectStateBlock)connectState;

//获取历史记录
- (void)getHistoryRecord:(checkRetBlock)blockCheck;

//关机
- (void)powerOff;

@end

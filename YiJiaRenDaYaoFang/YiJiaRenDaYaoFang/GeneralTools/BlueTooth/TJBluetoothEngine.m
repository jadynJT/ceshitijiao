//
//  TJBluetoothEngine.m
//  HeartRate
//
//  Created by qqc on 16/6/10.
//  Copyright © 2016年 Qqc. All rights reserved.
//

#import "TJBluetoothEngine.h"

static NSString * const kServiceUUID_peripheral1802 = @"1802";
static NSString * const kServiceUUID_peripheral1803 = @"1803";
static NSString * const kServiceUUID_peripheral1804 = @"1804";

static NSString * const kServiceUUIDFC00 = @"FC00";
static NSString * const kCharacteristicUUIDWriteFCA2 = @"FCA2";
static NSString * const kCharacteristicUUIDWriteFCA0 = @"FCA0";
static NSString * const kCharacteristicUUIDNotifyFCA1 = @"FCA1";

@interface TJBluetoothEngine()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic, strong) CBService* serverFC00;
@property (nonatomic, strong) CBCharacteristic* characteristicWriteFCA2;
@property (nonatomic, strong) CBCharacteristic* characteristicWriteFCA0;
@property (nonatomic, strong) CBCharacteristic* characteristicNotifyFCA1;

@property (nonatomic, assign) Byte codeBPM2APP;
@property (nonatomic, assign) Byte codeAPP2BPM;

//状态标识
@property (nonatomic, assign) BOOL bIsPeripheralConnected;
@property (nonatomic, assign) BOOL bIsBluetoothOn;
@property (nonatomic, copy) NSString *connectState;



@property (nonatomic, strong) TJBluetoothEngine* instance;

//数据回调
@property (nonatomic, copy)configCodeBlock blockConfigCode;
@property (nonatomic, copy)checkRetBlock blockCheckRet;
@property (nonatomic, copy)devPowerOffBlock blockPowerOff;
@property (nonatomic, copy)checkRetBlock blockCheckRetResult;
@property (nonatomic, copy)connectStateBlock blockConnectState;

@property (nonatomic, strong)NSMutableData* dataCheckRet;
@property (nonatomic, strong)NSMutableData* dataCheckRetResult;

@end

@implementation TJBluetoothEngine

#pragma mark  接口
- (void)launchWithBlock:(configCodeBlock)blockConfig autoCheckRet:(checkRetBlock)blockCheck devPowerOff:(devPowerOffBlock)blockPowerOff autoCheckRetResult:(checkRetResultBlock)blockCheckResult connectState:(connectStateBlock)connectState
{
    self.blockConfigCode = blockConfig;
    self.blockCheckRet = blockCheck;
    self.blockPowerOff = blockPowerOff;
    self.blockCheckRetResult = blockCheckResult;
    self.blockConnectState = connectState;
    
    [self restoreContext];
}


- (void)stop
{
    [self cleanup];
}

- (void)checkWithRet:(checkRetBlock)blockCheck checkWithRetResult:(checkRetResultBlock)blockCheckResult connectState:(connectStateBlock)connectState
{
    if (self.bIsBluetoothOn && !self.bIsPeripheralConnected) {
        [SVProgressHUD showInfoWithStatus:@"未检测到血压计，请在抽带正确卷绑后打开血压计"];
    }
    self.blockCheckRet = blockCheck;
    self.blockCheckRetResult = blockCheckResult;
    self.blockConnectState = connectState;
    
    [self reqCheck];
}

- (void)getHistoryRecord:(checkRetBlock)blockCheck
{
    self.blockCheckRet = blockCheck;
    [self getHistoryRecord];
}

- (void)powerOff
{
    [self powerOffTJBMP];
}

- (void)getBattery
{
    [self getBatteryTJBMP];
}

#pragma mark - 业务逻辑
- (void)restoreContext
{
    if (nil == self.manager) {
        
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }else if (NO == self.bIsBluetoothOn){
        self.connectState = @"未连接";
        if (self.blockConnectState) {
            self.blockConnectState(self.connectState);
        }
        
        [SVProgressHUD showInfoWithStatus:@"请检查蓝牙设备是否开启"];
    }else if (nil == self.peripheral){
        //扫描外部设备
        [self scanPeripherals];
    }else if (NO == self.bIsPeripheralConnected){
        //连接周边设备
        [self connectPeripherals];
    }else if (nil == self.serverFC00){
        //发现设备
        [self discoverServer];
    }else if (nil == self.characteristicWriteFCA2
              || nil == self.characteristicWriteFCA0
              || nil == self.characteristicNotifyFCA1){
        
        [self discoverCharacteristics];
    }
}

- (void)cleanup
{
    self.manager.delegate = nil;
    self.manager = nil;
    self.peripheral.delegate = nil;
    self.peripheral = nil;
    self.bIsPeripheralConnected = NO;
    self.characteristicWriteFCA0 = nil;
    self.characteristicWriteFCA2 = nil;
    self.characteristicNotifyFCA1 = nil;
    //[[DataCenter sharedDataCenter] clear];
    _strBattery = @"";
    _strConnectState = @"";
}

#pragma mark - 核心代码（与TJBMP交互）
- (void)scanPeripherals
{
    [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObjects: \
                                                  [CBUUID UUIDWithString:kServiceUUID_peripheral1802], \
                                                  [CBUUID UUIDWithString:kServiceUUID_peripheral1803], \
                                                  [CBUUID UUIDWithString:kServiceUUID_peripheral1804], \
                                                  nil] \
                                         options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)connectPeripherals
{
    [self.manager connectPeripheral:self.peripheral options:nil];
}

- (void)discoverServer
{
    [self.peripheral discoverServices: @[[CBUUID UUIDWithString:kServiceUUIDFC00]]];
}

- (void)discoverCharacteristics
{
    [self.peripheral discoverCharacteristics:nil forService:self.serverFC00];
}

- (void)reqConnectTJBMP
{
    if (self.characteristicWriteFCA2
        && self.characteristicNotifyFCA1
        && self.characteristicWriteFCA0) {
        
        NSLog(@"发送数据[%@]到UUID:%@",@"F0D2A9C60F01010008000400000000", self.characteristicWriteFCA2.UUID);
        
        NSData* data = [BluetoothDataParseHelper hexStrToBytes:@"F0D2A9C60F01010008000400000000"];
        [self.peripheral writeValue:data forCharacteristic:self.characteristicWriteFCA2 type:CBCharacteristicWriteWithResponse];
        
        
        NSLog(@"开始监听UUID的数据:%@", self.characteristicNotifyFCA1.UUID);
        [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristicNotifyFCA1];
        
        NSLog(@"发送数据[%@]到UUID:%@",@"0455AA03", self.characteristicWriteFCA0.UUID);
        NSData* data2 = [BluetoothDataParseHelper hexStrToBytes:@"0455AA03"];
        [self.peripheral writeValue:data2 forCharacteristic:self.characteristicWriteFCA0 type:CBCharacteristicWriteWithResponse];
    }else{
        [self restoreContext];
    }
}

- (void)reqCheck
{
    if (self.characteristicWriteFCA0){
        
        NSLog(@"发送数据[%@]到UUID（请求开始测量）:%@",@"04A2A147", self.characteristicWriteFCA0.UUID);
        NSData* data = [BluetoothDataParseHelper hexStrToBytes:@"04A2A147"];
        [self.peripheral writeValue:data forCharacteristic:self.characteristicWriteFCA0 type:CBCharacteristicWriteWithResponse];
    }else{
        [self restoreContext];
    }
}

- (void)respondConnect
{
    if (self.characteristicWriteFCA0) {
        
        Byte value[4] = {0};
             value[0] = 0x04;
             value[1] = self.codeAPP2BPM;
             value[2] = 0xA0;
        Byte* resultByte = (Byte*)[[BluetoothDataParseHelper getCheckSum:@"04A2A0"] bytes];
             value[3] = resultByte[0];
        NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
        
        NSLog(@"发送数据[%@]到UUID（请求获取配置码）:%@",[NSString stringWithFormat:@"%@", data], self.characteristicWriteFCA0.UUID);

        [self.peripheral writeValue:data forCharacteristic:self.characteristicWriteFCA0 type:CBCharacteristicWriteWithResponse];
    }else{
        [self restoreContext];
    }
}

- (void)getHistoryRecord
{
    if (self.characteristicWriteFCA0){
        
        NSLog(@"发送数据[%@]到UUID(请求获取历史记录):%@",@"04A2AC52", self.characteristicWriteFCA0.UUID);
        NSData* data = [BluetoothDataParseHelper hexStrToBytes:@"04A2AC52"];
        [self.peripheral writeValue:data forCharacteristic:self.characteristicWriteFCA0 type:CBCharacteristicWriteWithResponse];
    }else{
        [self restoreContext];
    }
}

// map方法
// 会遍历整个数组，并对数组中每个元素执行闭包定义的操作。即对数组中所有元素做一个映射。

// flatmap方法
// 和map基本一致
// 区别：1、flatmap会对多维数组降成一维
//      2、会将原数组中的nil值过滤
//      3、数组中的所有元素都会被解包

// 但如果结果是数组，则将它们连接到一个数组
// 3个函数均返回一个数组，将给定闭包映射到序列元素上
// compactMap 会过滤掉空元素
// flatMap    如果元素为数组，会将所有数组合并成同一个
// map        不会过滤nil元素和对多维数组降维，以及元素解包

// filter 数组过滤
// sort()、sort(by:) 数组排序
// forEach
// reduce


//forEach在每个元素上调用一个闭包。这意味着，与不同for-in，您不能使用break或continue，并且using return只能从当前的闭包调用中退出，而不能从包含方法中退出。下面的示例演示了这一点：

//func findFirstNegativeNumber(numbers: [Int]) -> Int? {
//    for number in numbers {
//        if number < 0 { return number }
//    }
//
//    return nil
//}
//
//let numbers = [82, 5, -25, 10, -99]
//print(findFirstNegativeNumber(numbers: numbers))
//// Prints Optional(-25)


//func findFirstNegativeNumber(numbers: [Int]) -> Int? {
//    numbers.forEach {
//        if $0 < 0 { return $0 }
//    }
//
//    return nil
//}
//
//let numbers = [82, 5, -25, 10, -99]
//print(findFirstNegativeNumber(numbers: numbers))
//// ❌ compilation error: unexpected non-void return value in void function
//// if $0 < 0 { return $0 }
////                    ^

- (void)powerOffTJBMP
{
    if (self.characteristicWriteFCA0){
        
        NSLog(@"发送数据[%@]到UUID（请求关机）:%@",@"04A2A64C", self.characteristicWriteFCA0.UUID);
        NSData* data = [BluetoothDataParseHelper hexStrToBytes:@"04A2A64C"];
        [self.peripheral writeValue:data forCharacteristic:self.characteristicWriteFCA0 type:CBCharacteristicWriteWithResponse];
    }else{
        [self restoreContext];
    }
}

- (void)getBatteryTJBMP
{
    if (self.characteristicWriteFCA0){
        
        NSLog(@"发送数据[%@]到UUID（请求获取电量）:%@",@"04A2A54B", self.characteristicWriteFCA0.UUID);
        NSData* data = [BluetoothDataParseHelper hexStrToBytes:@"04A2A54B"];
        [self.peripheral writeValue:data forCharacteristic:self.characteristicWriteFCA0 type:CBCharacteristicWriteWithResponse];
    }else{
        [self restoreContext];
    }
}

#pragma mark - CBCentralManagerDelegate 代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            //step1:通过服务查找周边
            NSLog(@"开始检查周边设备");
            self.bIsBluetoothOn = YES;
            if (!self.bIsPeripheralConnected) {
                [SVProgressHUD showInfoWithStatus:@"蓝牙打开成功，开始扫描设备"];
                
                self.connectState = @"正在连接中..";
                if (self.blockConnectState) {
                    self.blockConnectState(self.connectState);
                }
            }
            
            [self scanPeripherals];
            
            break;
        default:
            self.bIsBluetoothOn = NO;
            if (self.blockConfigCode) {
                self.blockConfigCode(nil);
            }
            
            self.connectState = @"未连接";
            if (self.blockConnectState) {
                self.blockConnectState(self.connectState);
            }
            
            NSLog(@"没有启动蓝牙或不支持蓝牙");
        
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self.manager stopScan];
    
    if (self.peripheral != peripheral) {
        
        self.peripheral = peripheral;
        NSLog(@"发现设备 %@", peripheral);
        //step2:连接周边
        double delayInSeconds = 2.0;
        __weak typeof(self)weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [weakSelf connectPeripherals];
        });
    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //发通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidConnectPeripheral"
                                                       object:@{@"central":central,@"peripheral":peripheral}];

    self.peripheral.delegate = self;
    NSLog(@"已连接设备 %@", peripheral);
    self.bIsPeripheralConnected = YES;
    
    self.connectState = @"已连接";
    if (self.blockConnectState) {
        self.blockConnectState(self.connectState);
    }

    
   [SVProgressHUD showInfoWithStatus:@"已连接设备"];
    
    //step3:查找该周边服务
    [self discoverServer];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
    [self cleanup];
    [self restoreContext];
    if (self.blockPowerOff) {
        
        self.blockPowerOff(YES);
    }
    
    self.connectState = @"未连接";
    if (self.blockConnectState) {
        self.blockConnectState(self.connectState);
    }
}

//连接到Peripherals-失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidConnectPeripheral"
                                                       object:@{@"central":central,@"peripheral":peripheral}];
    self.bIsPeripheralConnected = NO;
    self.connectState = @"未连接";
    if (self.blockConnectState) {
        self.blockConnectState(self.connectState);
    }
   
    [SVProgressHUD showInfoWithStatus:@"设备连接失败"];
}

#pragma mark - CBPeripheralDelegate 代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error) {
        
        NSLog(@"查找某服务出错:%@", [error localizedDescription]);
        if (self.blockConfigCode) {
            
            self.blockConfigCode(nil);
        }
        return;
    }
    
    for (CBService *service in peripheral.services) {
        
        NSLog(@"查找到服务UUID:%@",service.UUID);
        self.serverFC00 = service;
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUIDFC00]]) {
            
            //step4:查找某服务特征
            [self discoverCharacteristics];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    if (error) {
        
        NSLog(@"查找服务特征出错:%@", [error localizedDescription]);
        if (self.blockConfigCode) {
            
            self.blockConfigCode(nil);
        }
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUIDFC00]]) {
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUIDWriteFCA2]]) {
                
                self.characteristicWriteFCA2 = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUIDNotifyFCA1]]){
                
                self.characteristicNotifyFCA1 = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUIDWriteFCA0]]) {
                
                self.characteristicWriteFCA0 = characteristic;
            }
        }
    }
    
    if (self.characteristicWriteFCA0
        && self.characteristicNotifyFCA1
        && self.characteristicWriteFCA2) {
        
        [self reqConnectTJBMP];
    }
    
    
}

#pragma 数据交互代理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"更新通知特征FCA1失败: %@", [error localizedDescription]);
    }
    if (nil == characteristic.value) {
        [self reqConnectTJBMP];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"写入特征FCA0或FCA2失败: %@", [error localizedDescription]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"读取特征FCA1失败: %@", [error localizedDescription]);
        return;
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUIDNotifyFCA1]]) {
        
        NSData* data = characteristic.value;
        Byte * resultByte = (Byte *)[data bytes];
        
        if (0x55 == resultByte[1]) {
            //读取“厂商码”结果
            if (nil != resultByte) {
                self.codeBPM2APP = resultByte[2];
                self.codeAPP2BPM = resultByte[3];
            }
            NSLog(@"收到获取 厂商码 数据 = %@", data);
            [self respondConnect];
            
            if (self.blockConfigCode) {
                
                self.blockConfigCode(data);
            }
            
            [self getBattery];
            
            
        }else if (0xBA == resultByte[2])
        {
            NSLog(@"收到 关机信号 数据 = %@", data);

            [SVProgressHUD showWithStatus:@"血压计已关闭"];
            
            if (self.bIsBluetoothOn) {
                self.connectState = @"正在连接中..";
            }else{
                self.connectState = @"未连接";
            }

            if (self.blockConnectState) {
                self.blockConnectState(self.connectState);
            }
            
            [self cleanup];
            [self restoreContext];
            if (self.blockPowerOff) {
                
                self.blockPowerOff(YES);
            }
            
        }else if (0xB7 == resultByte[2])
        {
            NSLog(@"收到 测量过程 数据 = %@", data);
            //这里有修改
            if (self.blockCheckRet) {
                self.blockCheckRet(data);
            }
            
        }else if (0xB8 == resultByte[2])
        {
            NSLog(@"收到 测量结果 数据 = %@", data);
            
            [self.dataCheckRetResult resetBytesInRange:NSMakeRange(0, [data length])];
            [self.dataCheckRetResult setLength:0];

            [self.dataCheckRetResult appendData:data];
            
        }else if (0xB9 == resultByte[2])
        {
            NSLog(@"收到 测量错误信息 数据 = %@", data);
            
            if (self.blockCheckRet) {
                
                self.blockCheckRet(data);
            }
            
        }else if (0xBD == resultByte[2])
        {
            NSLog(@"收到 血压计上传结果测量的日期 数据 = %@", data);
            [self.dataCheckRetResult appendData:data];
            
        }else if (0xBE == resultByte[2])
        {
            NSLog(@"收到 血压计上传结果测量的时间 数据 = %@", data);
            [self.dataCheckRetResult appendData:data];

            if (self.blockCheckRetResult) {
                self.blockCheckRetResult(self.dataCheckRetResult);
            }
        }else if (0xB5 == resultByte[2]){
            NSLog(@"收到 血压计回复电量 数据 = %@", data);
            Byte * pressureByte = (Byte *)[data bytes];
            
            if(0xB5 == pressureByte[2]){
                //[DataCenter sharedDataCenter].strBattery = [NSString stringWithFormat:@"%hhu%@",pressureByte[3],@"%"];
                self.strBattery = [NSString stringWithFormat:@"%hhu%@",pressureByte[3],@"%"];
            }
            
            if (self.blockCheckRet) {
                self.blockCheckRet(data);
            }
        }else{
            
            NSLog(@"%@\n", data);
        }
    }
}

#pragma mark - 系统框架
+ (instancetype)shareTJBluetoothEngine
{
    static TJBluetoothEngine* instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(instancetype)init
{
    if (! (self=[super init]) )
    {
        return nil;
    }
    
    return self;
}

- (NSMutableData *)dataCheckRet
{
    if (nil == _dataCheckRet) {
        _dataCheckRet = [[NSMutableData alloc] init];
    }
    
    return _dataCheckRet;
}

- (NSMutableData *)dataCheckRetResult{
    if (nil == _dataCheckRetResult) {
        _dataCheckRetResult = [[NSMutableData alloc] init];
    }
    
    return _dataCheckRetResult;
}

- (void)setConnectState:(NSString *)connectState
{
    _connectState = connectState;
    _strConnectState = connectState;
    //[DataCenter sharedDataCenter].strConnectState = connectState;
}


//#pragma mark -- Timer
//- (void)measureTimeout{
//    NSLog(@"测量未收到结果");
//    [self reqConnectTJBMP];
//}
//
//- (void)timerTask{
//    
//}
@end

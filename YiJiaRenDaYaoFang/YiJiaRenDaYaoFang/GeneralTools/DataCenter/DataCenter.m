//
//  DataCenter.m
//  BaiXingDaYaoFang
//
//  Created by apple on 16/7/20.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "DataCenter.h"

@implementation DataCenter

SingletonM(DataCenter)//单例实现

- (DataModel *)lastAddMember
{
    if (nil == _lastAddMember) {
        _lastAddMember = [[DataModel alloc] init];
    }
    
    return _lastAddMember;
}

- (OtherOpenModel *)fromOtherApp
{
    if (nil == _fromOtherApp) {
        _fromOtherApp = [[OtherOpenModel alloc] init];
    }
    
    return _fromOtherApp;
}

@end

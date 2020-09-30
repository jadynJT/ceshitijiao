//
//  DataCenter.h
//  BaiXingDaYaoFang
//
//  Created by apple on 16/7/20.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModel.h"
#import "OtherOpenModel.h"
#import "Singleton.h"

@interface DataCenter : NSObject

SingletonH(DataCenter) //单例声明

@property(nonatomic, strong)DataModel* lastAddMember;
@property(nonatomic, strong)OtherOpenModel* fromOtherApp;

@end

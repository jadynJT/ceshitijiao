//
//  DataModel.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/6/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *uid;
@property (nonatomic,copy)NSString *phoneNum;


- (id)initWithDictionary:(NSDictionary *)dic;

@end

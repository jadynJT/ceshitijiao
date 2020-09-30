//
//  DataModel.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/6/29.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

- (void)dealloc{
    self.name = nil;
    self.uid = nil;
    self.phoneNum = nil;
}

- (id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.name = [dic objectForKey:@"name"];
        self.uid = [dic objectForKey:@"id"];
        self.phoneNum = [dic objectForKey:@"login_name"];
    }
    
    return self;
}


@end

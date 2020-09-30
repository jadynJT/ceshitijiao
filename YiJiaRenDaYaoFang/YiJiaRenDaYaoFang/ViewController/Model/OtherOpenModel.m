//
//  OtherOpenModel.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/12/26.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "OtherOpenModel.h"

@implementation OtherOpenModel

- (id)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.isOpened = [dic objectForKey:@"isOpened"];
        self.paramUrl = [dic objectForKey:@"paramUrl"];
    }
    
    return self;
}


@end

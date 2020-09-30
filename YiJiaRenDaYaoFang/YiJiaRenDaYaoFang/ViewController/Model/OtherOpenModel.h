//
//  OtherOpenModel.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/12/26.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherOpenModel : NSObject

@property (nonatomic,copy)NSString *paramUrl;
@property (nonatomic,assign)BOOL isOpened;

- (id)initWithDictionary:(NSDictionary *)dic;

@end

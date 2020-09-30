//
//  UIImage+Compress.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2018/4/23.
//  Copyright © 2018年 jztw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

@property (nonatomic, strong) NSData *imageData;

#pragma mark ----处理图片压缩
//+ (UIImage *)dealImageCompress:(NSData *)data
//                        toByte:(NSInteger)maxLength;

+ (UIImage *)compressImage:(UIImage *)image
                    toByte:(NSUInteger)maxLength;

@end

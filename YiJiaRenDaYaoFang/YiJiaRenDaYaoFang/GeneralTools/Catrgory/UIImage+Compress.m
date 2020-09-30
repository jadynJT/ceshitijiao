//
//  UIImage+Compress.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 2018/4/23.
//  Copyright © 2018年 jztw. All rights reserved.
//

#import "UIImage+Compress.h"
#import <objc/runtime.h>

static NSString *compressKey = @"compressKey"; // key

@implementation UIImage (Compress)

#pragma mark - 处理图片压缩
//+ (UIImage *)dealImageCompress:(NSData *)data
//                        toByte:(NSInteger)maxLength {
//
//    CGFloat length = [data length]/1000;
//    NSLog(@"length = %f",length);
//    //分享的缩略图不能超过了32k
//    if (length > maxLength) {
//        return [UIImage imageCompressForSize:[UIImage imageWithData:data] targetSize:CGSizeMake(150, 150)];
//    }
//    return [UIImage imageWithData:data];
//}

/**
 setter方法
 */
- (void)setImageData:(NSData *)imageData {
    objc_setAssociatedObject(self, &compressKey, imageData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSData *)imageData {
    return objc_getAssociatedObject(self, &compressKey);
}

// 压缩方法
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) {
        image.imageData = data;
        return image;
    }
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    
    if (data.length < maxLength) {
        resultImage.imageData = data;
        return resultImage;
    }
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    resultImage.imageData = data;
    return resultImage;
}

//+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = size.width;
//    CGFloat targetHeight = size.height;
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
//    if(CGSizeEqualToSize(imageSize, size) == NO){
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        if(widthFactor > heightFactor){
//            scaleFactor = widthFactor;
//        }
//        else{
//            scaleFactor = heightFactor;
//        }
//        scaledWidth = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        if(widthFactor > heightFactor){
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        }else if(widthFactor < heightFactor){
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//
//    UIGraphicsBeginImageContext(size);
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    [sourceImage drawInRect:thumbnailRect];
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    if(newImage == nil){
//        NSLog(@"scale image fail");
//    }
//    UIGraphicsEndImageContext();
//    return newImage;
//}

@end

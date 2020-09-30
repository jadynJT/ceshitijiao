//
//  CustomSegControl.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/12/31.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegControl : UIView

- (instancetype)initWithItemTitles:(NSArray *)itemTitles;

/**
 *  从0开始
 */
@property (nonatomic, copy) void(^CustomSegmentViewBtnClickHandle)(CustomSegControl *segment, NSString *currentTitle, NSInteger currentIndex);

- (void)clickDefault;

@end

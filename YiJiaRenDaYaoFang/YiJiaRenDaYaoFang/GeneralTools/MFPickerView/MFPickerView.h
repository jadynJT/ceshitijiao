//
//  MFPickerView.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 16/12/30.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MFPickerView;
typedef void(^MFPickViewSubmit)(NSDictionary *);

@interface MFPickerView : UIView<UIPickerViewDelegate>

@property (nonatomic, copy)MFPickViewSubmit block;

- (void)setDataViewWithItem:(NSArray *)items title:(NSString *)title;
- (void)showPickView:(UIView *)vc;

@end

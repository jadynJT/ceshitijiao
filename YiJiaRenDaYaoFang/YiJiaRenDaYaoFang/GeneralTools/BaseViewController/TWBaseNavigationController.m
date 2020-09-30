//
//  TWBaseNavigationController.m
//  86YYZX
//
//  Created by apple on 17/1/12.
//  Copyright © 2017年 TW. All rights reserved.
//

#import "TWBaseNavigationController.h"
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

//#import "UIBarButtonItem+Addition.h"


@interface TWBaseNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation TWBaseNavigationController

+ (void)initialize {
    // 设置为不透明
    [[UINavigationBar appearance] setTranslucent:NO];
    // 设置导航栏背景颜色
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    // 设置导航栏标题文字颜色
    // 创建字典保存文字大小和颜色
    NSMutableDictionary * color = [NSMutableDictionary dictionary];
    color[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    color[NSForegroundColorAttributeName] = [UIColor blackColor];
    [[UINavigationBar appearance] setTitleTextAttributes:color];
    
    // 拿到整个导航控制器的外观
    UIBarButtonItem * item = [UIBarButtonItem appearance];

    // 设置字典的字体大小
    NSMutableDictionary * atts = [NSMutableDictionary dictionary];
    atts[NSFontAttributeName] = [UIFont systemFontOfSize:17];

    // 将字典给item
    [item setTitleTextAttributes:atts forState:UIControlStateNormal];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count > 0)
    {
        /**
         *  如果在堆栈控制器数量大于1 加返回按钮
         */
        if (self.viewControllers.count > 0)
        {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [btn setImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\uE636",28,[UIColor blackColor])] forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, -18, 0, 0);
            btn.tintColor = [UIColor colorWithRed:0.42f green:0.33f blue:0.27f alpha:1.00f];
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
            [btn addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
            viewController.navigationItem.leftBarButtonItem = leftItem;
        }
        
        // push出来的View隐藏底部工具条
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

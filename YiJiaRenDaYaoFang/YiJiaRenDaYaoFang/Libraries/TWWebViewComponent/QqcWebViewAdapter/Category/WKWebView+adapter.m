//
//  WKWebView+adapter.m
//  QqcWebViewAdapter
//
//  Created by qiuqinchuan on 15/9/21.
//  Copyright (c) 2015年 ZQ. All rights reserved.
//

#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "WKWebView+adapter.h"

static void (*originalIMP)(id self, SEL _cmd, void* arg0, BOOL arg1, BOOL arg2, id arg3) = NULL;

void interceptIMP (id self, SEL _cmd, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
    originalIMP(self, _cmd, arg0, TRUE, arg2, arg3);
}


@implementation WKWebView (adapter)

#pragma mark - 框架方法
+ (void)load
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(loadRequest:);
        SEL swizzledSelector = @selector(swizzlingLoadRequest:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL bIsDidAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (bIsDidAddMethod)
        {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }
        else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - 属性
/*
 * Getter for the active request.
 */
- (NSURLRequest *)request
{
    return objc_getAssociatedObject(self, @selector(request));
}

/*
 * Setter for the active request.
 */
- (void)setRequest:(NSURLRequest *)request
{
    objc_setAssociatedObject(self, @selector(request), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 在分类中添加 -(instancetype)initWithFrame:(CGRect)frame

#pragma mark - 方法

- (NSURL *)URL
{
    return self.request.URL;
}

/**
 *  WKWebView 有不同的设置delegate的接口，这里做统一
 *  WKWebView 代理是 id <WKNavigationDelegate> navigationDelegate 和 id <WKUIDelegate> UIDelegate
 *  @param delegate id <WKNavigationDelegate,WKUIDelegate>
 */
- (void)setDelegateVC:(id)delegate
{
    [self setNavigationDelegate:delegate];
    [self setUIDelegate:delegate];
}

/**
 * 回退到上一个页面
 */
- (void)setGoBack
{
    if ([self canGoBack]) {
        [self goBack];
    }
}

/**
 * 重新刷新
 */
- (void)setReLoad
{
    [self reload];
}

/**
 *  通过字符串 url 加载
 *
 *  @param strUrl url字符串
 */
- (void)loadRequestWithString:(NSString *)strUrl
{
    [self loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString: strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15]];
}

#pragma mark - 内部方法
/*
 * 用于 swizzled 实例方法 loadRequest 的方法 （保存request对象）
 * @param request 请求对象
 */
- (void)swizzlingLoadRequest:(NSURLRequest *)request
{
    [self setRequest: request];
    
    [self swizzlingLoadRequest: request];
}

/**
 *  设置UserAgent
 *
 */
- (void)addToWebViewUserAgent:(NSString *)addAgent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable oldAgent, NSError * _Nullable error) {
            if (![oldAgent isKindOfClass:[NSString class]]) { 
                // 为了避免没有获取到oldAgent，所以设置一个默认的userAgent
                oldAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", [[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
            }
            
            // 自定义user-agent
            if (![(NSString *)oldAgent containsString:addAgent]) {
                NSString *newAgent = [oldAgent stringByAppendingFormat:@" TWAPP:%@/ipa",addAgent];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":newAgent}];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 一定要设置customUserAgent，否则执行navigator.userAgent拿不到oldAgent
                ((WKWebView *)self).customUserAgent = newAgent;
            }
            
        }];
    });
}

/**
 *  显示键盘（iOS12之前使用）
 *
 */
//- (void) wkWebViewShowKeybord {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class cls = NSClassFromString(@"WKContentView");
//        SEL originalSelector = NSSelectorFromString(@"_startAssistingNode:userIsInte      racting:blurPreviousNode:userObject:");
//        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
//        IMP impOvverride = (IMP) interceptIMP;
//        originalIMP = (void *)method_getImplementation(originalMethod);
//        method_setImplementation(originalMethod, impOvverride);
//    });
//}

/**
 *  web页面唤起键盘（iOS12使用）
 *
 */
- (void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
        });
        method_setImplementation(method, override);
    }
}

/**
 *  webView长屏幕截取（分段截取合成长图）
 *
 */
- (void)contentCaptureCompletionHandler:(void(^)(UIImage *capturedImage))completionHandler {
    // 制作了一个UIView的副本
    UIView *snapShotView = [self snapshotViewAfterScreenUpdates:YES];

    snapShotView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, snapShotView.frame.size.width, snapShotView.frame.size.height);

    [self.superview addSubview:snapShotView];

    // 获取当前UIView可滚动的内容长度
    CGPoint scrollOffset = self.scrollView.contentOffset;

    // 向上取整数 － 可滚动长度与UIView本身屏幕边界坐标相差倍数
    float maxIndex = ceilf(self.scrollView.contentSize.height/self.bounds.size.height);
    
    // 设置scrollView显示内容大小
    self.scrollView.contentSize = CGSizeMake(Screen_width*3, 0);
    
    // 保持清晰度
    UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, false, [UIScreen mainScreen].scale);

    // 滚动截图
    [self pageDraw:0 maxIndex:(int)maxIndex drawCallback:^{
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // 恢复原UIView 和 scrollView 的偏移
        [self.scrollView setContentOffset:scrollOffset animated:NO];
        [snapShotView removeFromSuperview];
        
        completionHandler(capturedImage);
    }];
}

// 滚动截图
- (void)pageDraw:(int)index maxIndex:(int)maxIndex drawCallback:(void(^)(void))drawCallback{
    [self.scrollView setContentOffset:CGPointMake(0, (float)index * (self.frame.size.height))];
    CGRect splitFrame = CGRectMake(0, (float)index * (self.frame.size.height), self.bounds.size.width, self.bounds.size.height);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawViewHierarchyInRect:splitFrame afterScreenUpdates:YES];
        if(index < maxIndex){
            [self pageDraw: index + 1 maxIndex:maxIndex drawCallback:drawCallback];
        }else{
            drawCallback();
        }
    });
}

@end







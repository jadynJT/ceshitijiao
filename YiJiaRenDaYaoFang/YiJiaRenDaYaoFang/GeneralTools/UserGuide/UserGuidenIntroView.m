//
//  UserGuidenIntroView.m
//  86YYZX
//
//  Created by apple on 2017/8/18.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import "UserGuidenIntroView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UserGuideIntroCell.h"
#import "AppDelegate.h"
#import "Masonry.h"

static NSString * const cellIdentifier = @"CellIdentifier";

@interface UserGuidenIntroView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<NSString *> *introImages;
@property (nonatomic, copy) void (^dismissBlock)(void);

@end

@implementation UserGuidenIntroView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configureSubviews];
    }
    return self;
}

+ (BOOL)firstLaunchAfterNewVersionInstalled {
    NSString *version = @"";
    NSString *versionCached = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppVersion"];
    if (NSOrderedDescending == [version compare:versionCached]) {
        return YES;
    }
    return NO;
}

+ (NSArray *)introImageNamesForCurrentVersion {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserGuide" ofType:@"plist"];
    if (!plistPath) return nil;
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if (!dict) return nil;
    
    NSDictionary *versionDict = [dict objectForKey:@""];
    if (!versionDict) return nil;
    
    return [versionDict objectForKey:@"IntroImages"];
}

- (void)initWithImages:(NSArray<NSString *> *)images dismissBlock:(void (^)(void))dismissBlock {
    self.introImages = images;
    self.dismissBlock = dismissBlock;
}

+ (UserGuidenIntroView *)showWithImages:(NSArray<NSString *> *)images dismissBlock:(void (^)(void))dismissBlock {
    UserGuidenIntroView *introController = [[UserGuidenIntroView alloc] initWithFrame:CGRectMake(0, 0, Screen_width, Screen_height)];
    [introController initWithImages:images dismissBlock:dismissBlock];
    
    return introController;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsZero;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UserGuideIntroCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    return _collectionView;
}

//配置子视图
- (void)configureSubviews {
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    //    [self.view addSubview:self.pageControl];
    //    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self.view.mas_centerX);
    //        make.bottom.equalTo(self.view.mas_bottom).offset(-100);
    //    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.introImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserGuideIntroCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.imageName = self.introImages[indexPath.item];
    
    if (indexPath.item < self.introImages.count - 1) {
        cell.dismissButton.hidden = YES;
    }
    else {
        cell.dismissButton.hidden = NO;
        
        __weak typeof(self) weakSelf = self;
        cell.dismissButtonAction = ^{
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"AppVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (weakSelf.dismissBlock) {
                weakSelf.dismissBlock();
            }
        };
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
//    self.pageControl.currentPage = index;
//}

#pragma mark - 禁止横屏
- (BOOL)shouldAutorotate {
    return NO;
}

@end

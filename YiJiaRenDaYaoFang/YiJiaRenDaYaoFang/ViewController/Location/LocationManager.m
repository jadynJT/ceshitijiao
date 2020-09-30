//
//  LocationManager.m
//  YiJiaRenDaYaoFang
//
//  Created by apple on 17/1/22.
//  Copyright © 2017年 TW. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

+ (instancetype)sharedLocationManager
{
    static LocationManager *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (! (self = [super init]) )
    {
        return nil;
    }
    
    return self;
}

#pragma 初始化百度地图用户位置管理类
/**
 *  初始化百度地图用户位置管理类
 */
- (void)initBMKUserLocation
{
    _locService = [[BMKLocationService alloc] init];
    [self startLocation];
    _locService.delegate = self;
    
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    _geocodesearch.delegate = self;
}

#pragma mark - 打开定位服务
/**
 *  打开定位服务
 */
- (void)startLocation
{
    [_locService startUserLocationService];
}

#pragma mark - 关闭定位服务
/**
 *  关闭定位服务
 */
- (void)stopLocation
{
    [_locService stopUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
    cllocation = userLocation.location;
    _clloction = cllocation;
    _userLatitude = cllocation.coordinate.latitude;
    _userLongitude = cllocation.coordinate.longitude;
    
    //地理反编码
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag){
        NSLog(@"反geo检索发送成功");
        [self stopLocation];//(如果需要实时定位不用停止定位服务)
    }else{
        NSLog(@"反geo检索发送失败");
    }
}

- (void)didStopLocatingUser {}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    [self stopLocation];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
#pragma mark -------------地理反编码的delegate---------------

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    _cityName = result.addressDetail.city;
    
    // poiList:         地址周边POI信息，成员类型为BMKPoiInfo
    // address:         地址名称
    // location:        地址坐标
    // addressDetail:   层次化地址信息
    // businessCircle:  商圈名称
}

@end

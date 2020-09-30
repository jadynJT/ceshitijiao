//
//  LocationManager.h
//  YiJiaRenDaYaoFang
//
//  Created by apple on 17/1/22.
//  Copyright © 2017年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import<BaiduMapAPI_Search/BMKPoiSearchType.h>

@interface LocationManager : NSObject<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    CLLocation *cllocation;
    BMKGeoCodeSearch *_geocodesearch; // 逆地理编码
}

@property (strong,nonatomic) BMKLocationService *locService;

// 城市名
@property (strong,nonatomic) NSString *cityName;

// 用户纬度
@property (nonatomic,assign) double userLatitude;

// 用户经度
@property (nonatomic,assign) double userLongitude;

// 用户位置
@property (strong,nonatomic) CLLocation *clloction;


// 初始化单例
+ (instancetype)sharedLocationManager;

// 初始化百度地图用户位置管理类
- (void)initBMKUserLocation;

// 开始定位
- (void)startLocation;

// 停止定位
- (void)stopLocation;




@end

//
//  MapFindHouseViewModel.h
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapFindHouseViewModel : NSObject

//每次刷新房源数的网络请求。。。。携带参数。。经纬度。。后台查找该经纬度周边的房源
+ (void)mapFindHouseWithLatitude:(NSString *)latitude andLongitude:(NSString *)longitude andScale:(NSString *)scale andHouseType:(NSString *)type andRentType:(NSString *)rentType andHouseSize:(NSString *)size andMinPrice:(NSString *)minPrice andMaxPrice:(NSString *)maxPrice andBlock:(void(^)(id result))block;

// 点击最大一级  请求小一级的数据
+ (void)mapFindNextHouseWithLatitude:(NSString *)latitude andLongitude:(NSString *)longitude andScale:(NSString *)scale andBlock:(void(^)(id result))block;

@end

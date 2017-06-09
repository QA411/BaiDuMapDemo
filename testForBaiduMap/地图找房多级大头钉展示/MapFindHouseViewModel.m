//
//  MapFindHouseViewModel.m
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "MapFindHouseViewModel.h"

@implementation MapFindHouseViewModel

// 最大一级的 请求
+ (void)mapFindHouseWithLatitude:(NSString *)latitude andLongitude:(NSString *)longitude andScale:(NSString *)scale andHouseType:(NSString *)type andRentType:(NSString *)rentType andHouseSize:(NSString *)size andMinPrice:(NSString *)minPrice andMaxPrice:(NSString *)maxPrice andBlock:(void(^)(id result))block {
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           @{@"lat": @"39.915",@"lng": @"116.404",@"description": @"啦啦小区",@"id": @"No101",@"minfee" : @"560万",@"houses" : @"32"},
                           @{@"lat": @"39.815",@"lng": @"116.380",@"description": @"爱情公寓",@"id": @"No102",@"minfee" : @"560万",@"houses" : @"20"},@{@"lat": @"39.885",@"lng": @"116.388",@"description": @"汉东大学",@"id": @"No103",@"minfee" : @"560万",@"houses" : @"20"},nil];
    block(arr);
    
}

// 点击最大一级  请求小一级的数据
+ (void)mapFindNextHouseWithLatitude:(NSString *)latitude andLongitude:(NSString *)longitude andScale:(NSString *)scale andBlock:(void(^)(id result))block {
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           @{@"lat": @"39.915",@"lng": @"116.404",@"description": @"小区-01",@"id": @"No101",@"minfee" : @"280万",@"houses" : @"32"},
                           @{@"lat": @"39.815",@"lng": @"116.380",@"description": @"小区-02",@"id": @"No102",@"minfee" : @"390万",@"houses" : @"20"},@{@"lat": @"39.885",@"lng": @"116.388",@"description": @"小区-03",@"id": @"No103",@"minfee" : @"560万",@"houses" : @"20"},nil];
    block(arr);
    
}



@end

//
//  FindHouseAnnotation.h
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface FindHouseAnnotation : NSObject<BMKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) UIImage *image;
@property(nonatomic, assign) NSInteger type;//在地图找房中1 大区  2 小区
@property(nonatomic, strong) NSString *Id;//可以是区域id 也可以是小区id
@property(nonatomic, strong) NSString *minPrice;//最低价格
@property(nonatomic, strong) NSString *messageAnnoIsBig;//当类型是message的时候。是否被放大了？yes/no

@end

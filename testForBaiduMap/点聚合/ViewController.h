//
//  ViewController.h
//  testForBaiduMap
//
//  Created by qq on 2017/6/8.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

// 点聚合  即为把适当范围（经纬度）内的点   通过缩放等级进行聚合展示。。
@interface ViewController : UIViewController<BMKMapViewDelegate>
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;


@end


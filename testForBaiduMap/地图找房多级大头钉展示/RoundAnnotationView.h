//
//  RoundAnnotationView.h
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface RoundAnnotationView : BMKAnnotationView

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *subTitle;
@property(nonatomic, strong) NSString *price;

@end

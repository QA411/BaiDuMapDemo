//
//  MessageAnnotationView.h
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MessageAnnotationView : BMKAnnotationView
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *messageAnnoIsBig;
-(void)didSelectedAnnotation:(MessageAnnotationView *)annotation;
-(void)didDeSelectedAnnotation:(MessageAnnotationView *)annotation;

@end

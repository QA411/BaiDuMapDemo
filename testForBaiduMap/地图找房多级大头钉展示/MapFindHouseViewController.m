//
//  MapFindHouseViewController.m
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "MapFindHouseViewController.h"

#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

#import "RoundAnnotationView.h"
#import "FindHouseAnnotation.h"
#import "MessageAnnotationView.h"
#import "MapFindHouseViewModel.h"

#define WeakSelf __weak __typeof(&*self)weakSelf = self;
@interface MapFindHouseViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
@property(nonatomic, strong) BMKMapView *mapView;//百度地图
@property(nonatomic, strong) BMKLocationService *locService;//定位服务
@property(nonatomic, assign) float zoomValue;//移动或缩放前的比例尺
@property(nonatomic, assign) CLLocationCoordinate2D oldCoor;//地图移动前中心经纬度
@property(nonatomic, strong) MessageAnnotationView *messageA;//记录点击过的大头针。便于点击空白时。把这个大头针缩小为原始大小

@end

@implementation MapFindHouseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"地图找房";
    [self setupUI];
}

#pragma mark -- UI

- (void)setupUI {
    
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.mapView];
    self.locService = [[BMKLocationService alloc] init];
    self.mapView.delegate = self;
    self.locService.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showMapScaleBar = YES;//显示比例尺
    self.mapView.mapScaleBarPosition = CGPointMake(10, 75);//比例尺位置
    self.mapView.minZoomLevel = 11;
    self.mapView.maxZoomLevel = 19;
    self.mapView.isSelectedAnnotationViewFront = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    [self.locService startUserLocationService];
    
    //创建编码对象 或者参见 点聚合 示例直接给予经纬度显示
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"北京" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil || placemarks.count == 0) {
            return;
        }
        //创建placemark对象
        CLPlacemark *placemark = [placemarks firstObject];
        NSLog(@"%f,%f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
        //赋值详细地址
        NSLog(@"详细地址 %@",placemark.name);
        CLLocationCoordinate2D coor;
        coor.latitude = placemark.location.coordinate.latitude;
        coor.longitude = placemark.location.coordinate.longitude;
        [self.mapView setCenterCoordinate:coor];
        [self.mapView setZoomLevel:13];
        self.zoomValue = 13;
    }];
    
    //请求大区 城市区域
    [self loadCityHouseAndBlock:^{
        
    }];
}

//请求城市区域内的房源组
- (void)loadCityHouseAndBlock:(void(^)())block {
    
    WeakSelf
    [MapFindHouseViewModel mapFindHouseWithLatitude:nil andLongitude:nil andScale:nil andHouseType:nil andRentType:nil andHouseSize:nil andMinPrice:nil andMaxPrice:nil andBlock:^(id result) {
        NSArray *data = result;
        if (data.count > 0) {
            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
         //请求大区
            for (NSDictionary *dic in data) {
                FindHouseAnnotation *an = [[FindHouseAnnotation alloc] init];
                CLLocationCoordinate2D coor;
                coor.latitude = [dic[@"lat"] floatValue];
                coor.longitude = [dic[@"lng"] floatValue];
                an.type = 1;
                an.coordinate = coor;
                an.title = dic[@"description"];
                an.subtitle = [NSString stringWithFormat:@"%@ 间",dic[@"houses"]];
                an.Id = dic[@"id"];
                an.minPrice = dic[@"minfee"];
                [weakSelf.mapView addAnnotation:an];
            }

            block();
        }else {
            NSLog(@"无房源！");
        }
    }];
}

// next 比大区小一级的区域  本工程示例也只有2级区域
- (void)nextloadAndBlock:(void(^)())block {
    
    WeakSelf
    [MapFindHouseViewModel mapFindNextHouseWithLatitude:nil andLongitude:nil andScale:nil andBlock:^(id result) {
        NSArray *data = result;
        if (data.count > 0) {
            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
            //请求小区
            for (NSDictionary *dic in data) {
                FindHouseAnnotation *an = [[FindHouseAnnotation alloc] init];
                CLLocationCoordinate2D coor;
                coor.latitude = [dic[@"lat"] floatValue];
                coor.longitude = [dic[@"lng"] floatValue];
                an.type = 2;
                an.coordinate = coor;
                an.title = [NSString stringWithFormat:@"%@ | %@间 | ¥%@起",dic[@"description"],dic[@"houses"],dic[@"minfee"]];
                an.Id = dic[@"id"];
                an.minPrice = dic[@"minfee"];
                [weakSelf.mapView addAnnotation:an];
            }
            block();
        }else {
            NSLog(@"无房源！");
        }
    }];
}

#pragma mark -- BMKLocationServiceDelegate

/**
 *在地图View将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
    NSLog(@"start locate");
}

/**
 *在地图View停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error");
}

#pragma mark -- BMMapViewDelegate
/**
 *点中底图空白处会回调此接口
 *@param mapView
 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
// 这种放大 点击恢复的效果非常不友好， 根据需求定制吧
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    for (FindHouseAnnotation *view in self.mapView.annotations) {
        if ([view.messageAnnoIsBig isEqualToString:@"yes"]) {
            //把放大过的大头针缩小
            [self.mapView deselectAnnotation:view animated:NO];
        }
    }
}

#pragma mark -- 回到用户的位置。
- (void)backUserLocation {
    //移动到用户的位置
    [self.mapView setCenterCoordinate:self.locService.userLocation.location.coordinate animated:YES];
}
//使用苹果原生库计算两个经纬度直接的距离

- (double)distanceBetweenFromCoor:(CLLocationCoordinate2D)coor1 toCoor:(CLLocationCoordinate2D)coor2 {
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:coor1.latitude longitude:coor1.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:coor2.latitude longitude:coor2.longitude];
    double distance  = [curLocation distanceFromLocation:otherLocation];
    return distance;
}
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self.mapView updateLocationData:userLocation];
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [self.mapView updateLocationData:userLocation];
}
//地图渲染完毕
- (void)mapViewDidFinishRendering:(BMKMapView *)mapView {
    
    //避免屏幕内没有房源-->计算屏幕右上角、左下角经纬度-->获取这个区域内所有的大头针-->判断有没有大头针-->若屏幕内没有，但整个地图中存在大头针-->移动中心点到这个大头针
    BMKCoordinateBounds coorbBound;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    northEast = [mapView convertPoint:CGPointMake(self.view.bounds.size.width, 0) toCoordinateFromView:mapView];
    southWest = [mapView convertPoint:CGPointMake(0, self.view.bounds.size.height) toCoordinateFromView:mapView];
    coorbBound.northEast = northEast;
    coorbBound.southWest = southWest;
    NSArray *annotations = [mapView annotationsInCoordinateBounds:coorbBound];
    if (annotations.count == 0 && mapView.annotations.count > 0 && mapView.zoomLevel != self.zoomValue) {
        FindHouseAnnotation *firstAnno = mapView.annotations.firstObject;
        //如果是个人位置的大头针。那么如果地图中大头针个数又大于1.取最后一个；否则return
        if (firstAnno.coordinate.latitude == self.locService.userLocation.location.coordinate.latitude) {
            NSLog(@"这是个个人位置大头针");
            if (mapView.annotations.count > 1) {
                firstAnno = mapView.annotations.lastObject;
            }else {
                return;
            }
        }
        [mapView setCenterCoordinate:firstAnno.coordinate animated:NO];
    }
    
}

- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation {
    // 生成重用标示identifier
    FindHouseAnnotation *anno = (FindHouseAnnotation *)annotation;
    
    if (anno.type == 1) {
        NSString *AnnotationViewID = @"round";
        // 检查是否有重用的缓存
        RoundAnnotationView *annotationView = (RoundAnnotationView *)[view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[RoundAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.paopaoView = nil;
        }
        // 设置偏移位置--->圆形不需要
        //        annotationView.centerOffset = CGPointMake(annotationView.frame.size.width * 0.5, -(annotationView.frame.size.height * 0.5));
        annotationView.title = anno.title;
        annotationView.subTitle = anno.subtitle;
        annotationView.price = [NSString stringWithFormat:@"¥%@ 起",anno.minPrice];
        annotationView.annotation = anno;
        annotationView.canShowCallout = NO;
        return annotationView;
        
    }else {
        
        NSString *AnnotationViewID = @"message";
        // 检查是否有重用的缓存
        MessageAnnotationView *annotationView = (MessageAnnotationView *)[view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[MessageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.paopaoView = nil;
        }
        // 设置偏移位置--->向上左偏移
        annotationView.centerOffset = CGPointMake(annotationView.frame.size.width * 0.5, -(annotationView.frame.size.height * 0.5));
        annotationView.title = anno.title;
        annotationView.annotation = anno;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    
    return nil;
}

//点击了大头针
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    if (view.annotation.coordinate.latitude == self.locService.userLocation.location.coordinate.latitude) {//个人位置特殊处理，否则类型不匹配崩溃
        NSLog(@"点击了个人位置");
        return;
    }
    FindHouseAnnotation *annotationView = (FindHouseAnnotation *)view.annotation;
    
    if (annotationView.type == 2) {
        
        MessageAnnotationView *messageAnno = (MessageAnnotationView *)view;
        //让点击的大头针放大效果
        [messageAnno didSelectedAnnotation:messageAnno];
        
        self.messageA = messageAnno;
        annotationView.messageAnnoIsBig = @"yes";
        //取消大头针的选中状态，否则下次再点击同一个则无法响应事件
        //        [mapView deselectAnnotation:annotationView animated:NO];
        //计算距离 --> 请求列表数据 --> 完成 --> 展示表格
        //        self.communityId = annotationView.Id;
        
    }else {
        //点击了区域--->进入小区
        
        [self nextloadAndBlock:^{
            
        }];
        //        //拿到大头针经纬度，放大地图。然后重新计算小区
        //        [mapView setCenterCoordinate:annotationView.coordinate animated:NO];
        //        [mapView setZoomLevel:16];
    }
}
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
    FindHouseAnnotation *annotationView = (FindHouseAnnotation *)view.annotation;
    if (annotationView.type == 2) {
        MessageAnnotationView *messageAnno = (MessageAnnotationView *)view;
        annotationView.messageAnnoIsBig = @"no";
        [messageAnno didDeSelectedAnnotation:messageAnno];
        [mapView mapForceRefresh];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

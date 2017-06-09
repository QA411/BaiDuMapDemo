//
//  ViewController.m
//  testForBaiduMap
//
//  Created by qq on 2017/6/8.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "ViewController.h"

#import "BMKClusterManager.h"
#import "Masonry.h"

#import "ClusterAnnotation.h"
#import "ClusterAnnotationView.h"


@interface ViewController (){
    BMKClusterManager *_clusterManager;//点聚合管理类
    NSInteger _clusterZoom;//聚合级别
    NSMutableArray *_clusterCaches;//点聚合缓存标注
}

@property (nonatomic , strong) BMKPointAnnotation* pointAnnotation;
@property (nonatomic , strong) BMKPointAnnotation* myAnnotation;

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.title = @"点聚合";
}
- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    //适配ios7
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        self.navigationController.navigationBar.translucent = NO;
//    }
    
    _clusterCaches = [[NSMutableArray alloc] init];
    for (NSInteger i = 3; i < 22; i++) {
        [_clusterCaches addObject:[NSMutableArray array]];
    }
    
    //点聚合管理类
    _clusterManager = [[BMKClusterManager alloc] init];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(39.915, 116.404);
    //向点聚合管理类中添加标注
    for (NSInteger i = 0; i < 13; i++) {
        double lat =  (arc4random() % 100) * 0.001f;
        double lon =  (arc4random() % 100) * 0.001f;
        BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
        clusterItem.coor = CLLocationCoordinate2DMake(coor.latitude + lat, coor.longitude + lon);
        [_clusterManager addClusterItem:clusterItem];
    }

}

//更新聚合状态
- (void)updateClusters {
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    @synchronized(_clusterCaches) {
        __block NSMutableArray *clusters = [_clusterCaches objectAtIndex:(_clusterZoom - 3)];
        
        if (clusters.count > 0) {
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotations:clusters];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                ///获取聚合后的标注
                __block NSArray *array = [_clusterManager getClusters:_clusterZoom];
                NSLog(@"Zoom=%ld",(long)_clusterZoom);
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (BMKCluster *item in array) {
                        ClusterAnnotation *annotation = [[ClusterAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        annotation.size = item.size;
                        annotation.titleName = [NSString stringWithFormat:@"我有%ld个", item.size];
                        [clusters addObject:annotation];
                    }
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView addAnnotations:clusters];
                });
            });
        }
    }
}

#pragma mark - BMKMapViewDelegate

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //    //普通annotation
    if ([annotation isKindOfClass:[ClusterAnnotation class]]) {
        
        static NSString * const myAnnotationViewID = @"ClusterMark";
        ClusterAnnotation *cluster = (ClusterAnnotation*)annotation;
        ClusterAnnotationView *annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myAnnotationViewID];
        //    annotationView.size = cluster.size;
        annotationView.draggable = YES;
        annotationView.annotation = cluster;
        //    annotationView.annotationImageView.image = [UIImage imageNamed:@"地图_红色_气泡@3x"];
        annotationView.image = [UIImage imageNamed:@"地图_红色_气泡@3x"];
        annotationView.titleLabel.text = cluster.titleName;//[NSString stringWithFormat:@"%@,下属%ld个", cluster.titleName, cluster.size];
        return annotationView;
        
    }
    return nil;
    
    
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    
    NSLog(@"didSelectAnnotationView");
    
    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation*)view.annotation;
        if (clusterAnnotation.size > 1) {
            [mapView setCenterCoordinate:view.annotation.coordinate];
            [mapView zoomIn];
        }
    }
    
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation*)view.annotation;
        if (clusterAnnotation.size > 1) {
            [mapView setCenterCoordinate:view.annotation.coordinate];
            [mapView zoomIn];
        }
    }
}

/**
 *地图初始化完毕时会调用此接口
 *@param mapView 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    [self updateClusters];
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapView 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel) {
        [self updateClusters];
    }
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

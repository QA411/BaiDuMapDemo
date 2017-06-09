//
//  ClusterAnnotationView.m
//  testForBaiduMap
//
//  Created by qq on 2017/6/8.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "ClusterAnnotationView.h"
#import "Masonry.h"

@implementation ClusterAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBounds:CGRectMake(0.f, 0.f, 80, 30)];
        
//        _annotationImageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        _annotationImageView.image = [UIImage imageNamed:@"地图_红色_气泡"];
//        [self addSubview:_annotationImageView];
//        [_annotationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            
//            make.left.right.top.bottom.equalTo(self);
//            
//        }];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, self.bounds.size.width, 15)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-6);
            
        }];
        
        self.alpha = 0.85;
        self.canShowCallout = NO;
    }
    return self;
}


@end

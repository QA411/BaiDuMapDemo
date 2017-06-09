//
//  FindHouseAnnotation.m
//  testForBaiduMap
//
//  Created by qq on 2017/6/9.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "FindHouseAnnotation.h"

@implementation FindHouseAnnotation
//重写判定两个对象相等的逻辑
- (BOOL)isEqual:(FindHouseAnnotation *)object {
    //如果两个大头针的title一样，那么就是同一个大头针 也可以判定经纬度一样
    return [self.title isEqual:object.title];
}
@end

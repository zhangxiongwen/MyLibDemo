//
//  PYLineSeries.m
//  iOS-Echarts
//
//  Created by Pluto Y on 15/9/8.
//  Copyright (c) 2015年 pluto-y. All rights reserved.
//

#import "PYCartesianSeries.h"

@implementation PYCartesianSeries

- (instancetype)init
{
    self = [super init];
    if (self) {
        _barGap = @"30%";
        _barCategoryGap = @"30%";
        _showAllSymbol = NO;
        _smooth = NO;
        _dataFilter = @"nearst";
        _large = NO;
        _largeThreshold = @(2000);
        _legendHoverLink = YES;
    }
    return self;
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
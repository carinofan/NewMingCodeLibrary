//
//  HTTPRequestDataModel.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/23.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "HTTPRequestDataModel.h"

@implementation HTTPRequestDataModel

- (instancetype)init{
    self = [super init];
    if (self) {
        _timerOutInterval = 30.0;
        _supportHttps = YES;
    }
    return self;
}

@end

@implementation HTTPRequestDownload

- (instancetype)init{
    self = [super init];
    if (self) {
        _rangeBytes = 0;
    }
    return self;
}

@end

@implementation HTTPRequestUpload


@end
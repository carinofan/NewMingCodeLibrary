//
//  AFTestCase.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/19.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "AFTestCase.h"

NSString * const AFNetworkingTestsBaseURLString = @"http://www.cocoachina.com";
NSString * const baseAFURL = @"https://httpbin.org/";

@implementation AFTestCase

- (void)setUp {
    [super setUp];
    
    [Expecta setAsynchronousTestTimeout:5.0];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark -

- (NSURL *)baseURL{
    return [NSURL URLWithString:AFNetworkingTestsBaseURLString];
}

- (NSURL *)baseAFURL{
    return [NSURL URLWithString:baseAFURL];
}

@end

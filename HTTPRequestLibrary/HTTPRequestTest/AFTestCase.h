//
//  AFTestCase.h
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/19.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#define EXP_SHORTHAND YES

#import "Expecta.h"
#import "OCMock.h"

extern NSString * const AFNetwrokingTestsBaseURLString;

@interface AFTestCase : XCTestCase

@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSURL *baseAFURL;

@end

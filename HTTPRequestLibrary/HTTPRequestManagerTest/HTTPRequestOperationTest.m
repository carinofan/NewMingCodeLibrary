//
//  HTTPRequestOperationTest.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/23.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Expecta.h"
#import "OCMock.h"
#import "HTTPRequestManager.h"
#import "HttpRequestOperation.h"

@interface HTTPRequestOperationTest : XCTestCase

@end

@implementation HTTPRequestOperationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPauseResumeStallsHTTPThread{
    [Expecta setAsynchronousTestTimeout:5.0];
    
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSString *baseURL = @"https://www.baidu.com";
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = baseURL;
    data.parameters = nil;
    HttpRequestOperation *operation = [manager PostXml:data success:^(id responseObject) {
        blockResponseObject = responseObject;
//        NSLog(@"%@",responseObject);
    } failure:^(id responseObject, NSError *error) {
        blockError = error;
//        NSLog(@"%@",error);
    }];
    [operation start];
    [operation pause];
    expect([operation isPaused]).will.beTruthy();
    
    [operation resume];
    expect([operation isExecuting]).will.beTruthy();
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(blockResponseObject).willNot.beNil();
}

- (void)testPauseResumeCancelStallsHTTPThread{
    [Expecta setAsynchronousTestTimeout:5.0];
    
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSString *baseURL = @"https://www.baidu.com";
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = baseURL;
    data.parameters = nil;
    HttpRequestOperation *operation = [manager PostXml:data success:^(id responseObject) {
        blockResponseObject = responseObject;
        //        NSLog(@"%@",responseObject);
    } failure:^(id responseObject, NSError *error) {
        blockError = error;
        //        NSLog(@"%@",error);
    }];
    [operation start];
    [operation pause];
    expect([operation isPaused]).will.beTruthy();
    
    [operation resume];
    expect([operation isExecuting]).will.beTruthy();
    
    [operation cancel];
    expect([operation isCancelled]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(blockResponseObject).will.beNil();
}

@end

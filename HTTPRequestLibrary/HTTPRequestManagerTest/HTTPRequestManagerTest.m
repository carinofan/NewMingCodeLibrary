//
//  HTTPRequestManagerTest.m
//  HTTPRequestManagerTest
//
//  Created by Fanming on 15/12/22.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Expecta.h"
#import "OCMock.h"
#import "HTTPRequestManager.h"
#import "HTTPRequestDataModel.h"

@interface HTTPRequestManagerTest : XCTestCase

@property (strong, nonatomic)HTTPRequestManager *manager;

@end

@implementation HTTPRequestManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _manager = [HTTPRequestManager manager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHTTPReqeustUsePostReturnXMLData{
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSString *baseURL = @"http://itech.billionscatalog.net/getservers/";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"5" forKey:@"Ver"];
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = baseURL;
    data.parameters = dictionary;
    data.supportHttps = NO;
    [self.manager PostXml:data success:^(id responseObject) {
        blockResponseObject = responseObject;
    } failure:^(id responseObject, NSError *error) {
        blockError = error;
    }];
    
    expect(blockResponseObject).willNot.beNil();
    expect(blockError).will.beNil();
}

- (void)testHTTPSReqeustUsePostReturnXMLData{
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSString *baseURL = @"https://itech.billionscatalog.net/getservers/";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"5" forKey:@"Ver"];
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = baseURL;  
    data.parameters = dictionary;
    [self.manager PostXml:data success:^(id responseObject) {
        blockResponseObject = responseObject;
    } failure:^(id responseObject, NSError *error) {
        blockError = error;
    }]; 
    
    expect(blockResponseObject).willNot.beNil();
    expect(blockError).will.beNil();
}

- (void)testHTTPReqeustUsePostReturnXMLDataButDataNotisXML{
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSString *baseURL = @"https://www.baidu.com";
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = baseURL;
    data.parameters = nil;
    [self.manager PostXml:data success:^(id responseObject) {
        blockResponseObject = responseObject;
    } failure:^(id responseObject, NSError *error) {
        blockError = error;
    }];
    
    expect(blockResponseObject).willNot.beNil();
    expect(blockError).will.beNil();
}

- (void)testHTTPRequestUseHead{
    __block NSInteger blockResponseObject;
    __block id blockError = nil;
    
    NSString *baseURL = @"https://www.baidu.com";
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = baseURL;
    data.parameters = nil;
    [self.manager Head:data success:^(id responseObject) {
        
        NSHTTPURLResponse *response = [(AFHTTPRequestOperation *)responseObject response];
        blockResponseObject = (long)[response statusCode];
//        NSLog(@"sadfas%li",(long)blockResponseObject);
    } failure:^(id responseObject, NSError *error) {
        blockError = error;
    }];
    
    expect(blockResponseObject).will.equal(200);
    expect(blockError).will.beNil();
}

- (void)testHTTPDownload{
    NSString *baseURL = @"http://119.81.165.162:8084/BillionsCatalog/home/download_magazine";
    id mockParameters = OCMStrictClassMock([NSMutableDictionary class]);
    
    
    
    
    
    
}


@end

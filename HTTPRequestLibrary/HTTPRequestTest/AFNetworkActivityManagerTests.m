//
//  AFNetworkActivityManagerTests.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/28.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "AFTestCase.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"

@interface AFNetworkActivityManagerTests : AFTestCase
@property (nonatomic, strong) AFNetworkActivityIndicatorManager *networkActivityIndicatorManager;
@property (nonatomic, assign) BOOL isNetworkActivityIndicatorVisible;
@property (nonatomic, strong) id mockApplication;
@end

@implementation AFNetworkActivityManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkActivityIndicatorManager = [[AFNetworkActivityIndicatorManager alloc]init];
    self.networkActivityIndicatorManager.enabled = YES;
    
    self.mockApplication = OCMClassMock([UIApplication class]);
    OCMStub([self.mockApplication sharedApplication]).andReturn(self.mockApplication);
    OCMStub([self.mockApplication isNetworkActivityIndicatorVisible]).andDo(^(NSInvocation *invocation){
        [invocation setReturnValue:(void *)&_isNetworkActivityIndicatorVisible];
    });
    OCMStub([self.mockApplication setNetworkActivityIndicatorVisible:YES]).andDo(^(NSInvocation *invocation){
        [invocation getArgument:&_isNetworkActivityIndicatorVisible atIndex:2];
    });
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.mockApplication stopMocking];
    
    self.mockApplication = nil;
    self.networkActivityIndicatorManager = nil;
}

- (void)testThatNetworkActivityIndicatorTurnsOffIndicatorWhenRequestSucceeds{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/swift" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        expect([self.mockApplication isNetworkActivityIndicatorVisible]).will.beFalsy();
    } failure:nil];
    
    [operation start];
    
    expect([self.mockApplication isNetworkActivityIndicatorVisible]).will.beTruthy();
    
}

@end

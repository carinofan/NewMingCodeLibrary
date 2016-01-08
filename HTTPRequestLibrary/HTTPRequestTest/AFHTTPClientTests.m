//
//  AFHTTPClientTests.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/28.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "AFNetworkingTests.h"

@interface AFHTTPClientTests : AFNetworkingTests

@property (readwrite, nonatomic, strong) AFHTTPSessionManager *client;

@end

@implementation AFHTTPClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AFNetworkingTestsBaseURLString]];
}

- (void)testThatEnqueueBatchOfHTTPRequestOperationsConstructsOperationsWithAppropriateRegisteredHTTPRequestOperationClasses{
    
}

@end

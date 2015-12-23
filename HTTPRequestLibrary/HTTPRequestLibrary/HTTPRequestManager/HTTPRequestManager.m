//
//  HTTPRequestManager.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/22.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "HTTPRequestManager.h"

@implementation HTTPRequestManager

-(instancetype)init{
    return [self initWithBaseURL:nil];
}

+ (instancetype)manager{
    return [[self alloc]initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url{
    self = [super init];
    if (self) {
        self.supportHttps = NO;
        self.timerOutInterval = 30.0;
    }
    return self;
}

- (HttpRequestOperation *)PostXml:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(id, NSError *))failure{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [operationManager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [operationManager.requestSerializer setTimeoutInterval:self.timerOutInterval];
    
    AFHTTPRequestOperation *requestOperation = [operationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success([operation responseString]);
//        NSLog(@"%@",operation.responseString);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure([operation responseString],error);
//        NSLog(@"%@\n%@",operation.responseString, error);
    }];
    if (self.supportHttps) {
        requestOperation.securityPolicy.allowInvalidCertificates = YES;
    }
    
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc]initWithOperation:requestOperation];
    
    return httpOperation;
}

- (HttpRequestOperation *)Head:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(id responseObject, NSError *error))failure{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [operationManager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [operationManager.requestSerializer setTimeoutInterval:self.timerOutInterval];
    
    AFHTTPRequestOperation *operationReqeust = [operationManager HEAD:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation) {
        success(operation);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(operation, error);
    }];
    
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc]initWithOperation:operationReqeust];
    return httpOperation;
}



@end

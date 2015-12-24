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
    }
    return self;
}

- (HttpRequestOperation *)Head:(HTTPRequestDataModel *)dataModel success:(void (^)(id))success failure:(void (^)(id responseObject, NSError *error))failure{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [operationManager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [operationManager.requestSerializer setTimeoutInterval:dataModel.timerOutInterval];
    
    AFHTTPRequestOperation *operationReqeust = [operationManager HEAD:dataModel.baseString parameters:dataModel.parameters success:^(AFHTTPRequestOperation * _Nonnull operation) {
        success(operation);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(operation, error);
    }];
    
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc]initWithOperation:operationReqeust];
    return httpOperation;
}

- (HttpRequestOperation *)PostXml:(HTTPRequestDataModel *)dataModel  success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [operationManager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [operationManager.requestSerializer setTimeoutInterval:dataModel.timerOutInterval];
    
    AFHTTPRequestOperation *requestOperation = [operationManager POST:dataModel.baseString parameters:dataModel.parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success([operation responseString]);
        //        NSLog(@"%@",operation.responseString);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure([operation responseString],error);
        //        NSLog(@"%@\n%@",operation.responseString, error);
    }];
    if (dataModel.supportHttps) {
        requestOperation.securityPolicy.allowInvalidCertificates = YES;
    }
    
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc]initWithOperation:requestOperation];
    
    return httpOperation;
}

- (HttpRequestOperation *)PostDownload:(HTTPRequestDownload *)dataModel success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/zip"];
    
    if (dataModel.rangeBytes > 0) {
        NSString * requestRange = [NSString stringWithFormat:@"bytes=%@-",dataModel.rangeBytes];
        [operationManager.requestSerializer setValue:requestRange
                         forHTTPHeaderField:@"Range"];
    }
    
    AFHTTPRequestOperation *requestOperation = [operationManager POST:dataModel.baseString parameters:dataModel.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL URLWithString:dataModel.subPath] name:dataModel.fileName error:nil];
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(operation);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(operation, error);
    }];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",dataModel.subPath, dataModel.fileName];
    requestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
    
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc] initWithOperation:requestOperation];
    return httpOperation;
}

- (HttpRequestOperation *)PostUpload:(HTTPRequestUpload *)dataModel success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager.requestSerializer setValue:@"gzip" forKey:@"Accept-Encoding"];
    operationManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    AFHTTPRequestOperation *requestOperation = [operationManager POST:dataModel.baseString parameters:dataModel.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (dataModel.uploadData) {
            [formData appendPartWithFileData:dataModel.uploadData name:@"portrait" fileName:dataModel.fileName mimeType:dataModel.fileType];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
    }];
    
    HttpRequestOperation *httpOperation = [[HttpRequestOperation alloc] initWithOperation:requestOperation];
    return httpOperation;
}

@end

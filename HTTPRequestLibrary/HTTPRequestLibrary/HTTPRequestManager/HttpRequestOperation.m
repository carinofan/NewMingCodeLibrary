//
//  HttpRequestOperation.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/22.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "HttpRequestOperation.h"

@interface HttpRequestOperation ()

@property (strong, nonatomic) AFHTTPRequestOperation *operation;

@end

@implementation HttpRequestOperation

- (instancetype)initWithOperation:(AFHTTPRequestOperation *)operation{
    self = [super init];
    if (self) {
        _operation = operation;
    }
    return self;
}

- (void)start{
    [self.operation start];
}

- (void)resume{
    [self.operation resume];
}

- (void)pause{
    [self.operation pause];
}

- (BOOL)isPaused{
    return [self.operation isPaused];
}

- (BOOL)isExecuting{
    return [self.operation isExecuting];
}

- (BOOL)isFinished{
    return [self.operation isFinished];
}

- (void)cancel{
    [self.operation cancel];
}

- (BOOL)isCancelled{
    return [self.operation isCancelled];
}

- (void)setUploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block{
    [self.operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        block(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }];
}

- (void)setDownloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))block {
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        block(bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
}

@end

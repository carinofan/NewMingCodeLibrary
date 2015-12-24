//
//  HttpRequestOperation.h
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/22.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface HttpRequestOperation : NSObject

- (nullable instancetype)initWithOperation:(nullable AFHTTPRequestOperation *)operation;

- (void)pause;

- (BOOL)isPaused;

- (void)resume;

- (void)start;

- (BOOL)isExecuting;

- (BOOL)isFinished;

- (void)cancel;

- (BOOL)isCancelled;

- (void)setUploadProgressBlock:(nullable void (^)(NSUInteger bytesWritten, long long tatalBytesWritten, long long totalBytesExpectedToWrite))block;

- (void)setDownloadProgressBlock:(nullable void (^)(NSUInteger bytesRead, long long tatalBytesRead, long long totalBytesExpectedToRead))block;

@end

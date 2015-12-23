//
//  AFHTTPSessionManagerTests.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/22.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//
#import "AFTestCase.h"
#import "AFHTTPSessionManager.h"

@interface AFHTTPSessionManagerTests : AFTestCase
@property (readwrite, nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation AFHTTPSessionManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.manager invalidateSessionCancelingTasks:YES];
    [super tearDown];
}

- (void)testThatOperationInvokesCompletionHandlerWithResponseObjectOnSuccess{
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/get" relativeToURL:self.baseAFURL]];
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        blockResponseObject = responseObject;
        blockError = error;
    }];
    
    [task resume];
    
    expect(task.state).will.equal(NSURLSessionTaskStateCompleted);
    expect(blockError).will.beNil();
    expect(blockResponseObject).willNot.beNil();
}

- (void)testThatOperationInvokeseFailureCompletionBlockWithErrorOnFilure{
    __block id blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/status/404" relativeToURL:self.baseAFURL]];
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        blockError = error;
    }];
    
    [task resume];
    expect(task.state).will.equal(NSURLSessionTaskStateCompleted);
    expect(blockError).willNot.beNil();
    
}

- (void)testThatRedirectBlockIsCalledWhen302IsEncountered {
    __block BOOL success;
    __block NSError *blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/redirect/1" relativeToURL:self.baseAFURL]];
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        blockError = error;
    }];
    
    [self.manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
        if (response) {
            success = YES;
        }
        return request;
    }];
    
    [task resume];
    
    expect(task.state).will.equal(NSURLSessionTaskStateCompleted);
    expect(blockError).will.beNil();
    expect(success).will.beTruthy();
}

- (void)testDownloadFileCompletionSpecifiesURLInCompletionWithManagerDidFinishBlock {
    __block BOOL managerDownloadFinishedBlockExecuted = NO;
    __block BOOL completionBlockExecuted = NO;
    __block NSURL *downloadFilePath = nil;
    
    [self.manager setDownloadTaskDidFinishDownloadingBlock:^NSURL * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, NSURL * _Nonnull location) {
        managerDownloadFinishedBlockExecuted = YES;
        NSURL *dirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask]lastObject];
        return [dirURL URLByAppendingPathComponent:@"t1/file"];
    }];
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:[NSURLRequest requestWithURL:self.baseAFURL] progress:nil destination:nil completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        downloadFilePath = filePath;
        completionBlockExecuted = YES;
    }];
    
    [downloadTask resume];
    expect(completionBlockExecuted).will.equal(YES);
    expect(managerDownloadFinishedBlockExecuted).will.equal(YES);
    expect(downloadFilePath).willNot.beNil();
    
}

- (void)testDownloadFileCompletionSpecifiesURLInCompletionBlock{
    __block BOOL destinationBlockExecuted = NO;
    __block BOOL completionBlockExecuted = NO;
    __block NSURL *downloadFilePath = nil;
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:[NSURLRequest requestWithURL:self.baseAFURL] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        destinationBlockExecuted = YES;
        NSURL *dirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask]lastObject];
        return [dirURL URLByAppendingPathComponent:@"t1.file"];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        downloadFilePath = filePath;
        completionBlockExecuted = YES;
        
    }];
    [downloadTask resume];
    expect(completionBlockExecuted).will.equal(YES);
    expect(destinationBlockExecuted).will.equal(YES);
    expect(downloadFilePath).willNot.beNil();
    
}

@end

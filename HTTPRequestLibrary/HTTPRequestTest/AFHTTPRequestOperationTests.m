//
//  AFHTTPRequestOperationTests.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/19.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//
#import "AFTestCase.h"
//#import "EXPMatchers+beTruthy.h"
#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperationTests : AFTestCase

@end

@implementation AFHTTPRequestOperationTests

- (void)testPauseResumeStallsNetworkThread {
    [Expecta setAsynchronousTestTimeout:5.0];
    
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/iOS" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockResponseObject = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockError = error;
    }];
    
    // FLAKY: For this test to correctly fail, 'pause' must happen on the main thread before the network thread has run the logic of 'start'.
    // The non-intrusive fix to this is to create fine grained control over the starting/stopping of the network thread, rather than having the network thread continually process events in the background.
    
    // Start, and then immediately pause the connection.
    // The pause should correctly reset the state of the operation.
    // This test fails when pause incorrectly resets the state of the operation.
    [operation start];
    [operation pause];
    expect([operation isPaused]).will.beTruthy();
    
    // Resume the operation.
    [operation resume];
    expect([operation isExecuting]).will.beTruthy();
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(blockResponseObject).willNot.beNil();
    
    // The first operation completed, but the network thread is now in an infinite loop.
    // Future requests should not work.
    blockResponseObject = nil;
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockResponseObject = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockError = error;
    }];
    
    // The network thread is stalled, so this operation could not succeed.
    [operation2 start];
    expect(blockError).will.beNil();
    expect(blockResponseObject).willNot.beNil();
}


- (void)testThatOperationInvokesSuccessCompletionBlockWithResponseObjectOnSuccess {
    __block id blockResponseOjbect = nil;
    __block id blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/swift" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        blockResponseOjbect = responseObject;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(blockResponseOjbect).willNot.beNil();
    
}

- (void)testThatOperationInvokesSuccessCompletionBlockOn204{
    __block id blockResponseObject = nil;
    __block NSError *blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/status/204" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        blockResponseObject = responseObject;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil;
    expect(blockResponseObject).will.equal([NSData data]);
}

- (void)testThatOperationInvokesFailureCompletionBlockWithErrorOnFailure {
    __block NSError *blockError = nil;
    
    NSURLRequest *reuqest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/status/404" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:reuqest];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).willNot.beNil();
    
}

- (void)testThatCancellationOfRequestOperationSetsError {
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/appstore" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:requst];
    
    [operation start];
    expect([operation isExecuting]).will.beTruthy();
    
    [operation cancel];
    expect(operation.error).willNot.beNil();
    expect(operation.error.code).to.equal(NSURLErrorCancelled);
    
}

- (void)testThatCancellationOfRequestOperationInvokesFailureCompletionBlock {
    __block NSError *blockError = nil;
    
    NSURLRequest *reqest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/appstore" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:reqest];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    expect([operation isExecuting]).will.beTruthy();
    
    [operation cancel];
    expect(operation.error).willNot.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorCancelled);
}

- (void)testThatCancellationOfRequestBeforeStartingRequestSetsError {
    __block NSError *blockError = nil;
    
    NSURLRequest *reqest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/appstore" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:reqest];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation cancel];
    [operation start];
    
    expect([operation isCancelled]).will.beTruthy();
    expect([operation isFinished]).will.beTruthy();
    expect([operation isExecuting]).will.beFalsy();
    
    expect(operation.error).willNot.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorCancelled);
    
}

- (void)testThat500StatusCodeInvokesFailureCompletioinBlockWithErrorOnFailure {
    __block NSError *blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/statue/500" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).willNot.beNil();
    
}

- (void)testThatRedirectBlockIsCalledWhen302IsEncountered{
    __block BOOL success;
    __block NSError *blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/redirect/1" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    [operation setRedirectResponseBlock:^NSURLRequest * _Nonnull(NSURLConnection * _Nonnull connection, NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull redirectResponse) {
        if (redirectResponse) {
            success = YES;
        }
        return request;
    }];
    
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(success).will.beTruthy();
}

- (void)testThatRedirectBlockIsCalledMultipleTimesWhenMultiple302sAreEncountered {
    [Expecta setAsynchronousTestTimeout:5.0];
    __block NSInteger numberOfRedirects = 0;
    __block NSError *blockError = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/redirect/5" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    [operation setRedirectResponseBlock:^NSURLRequest * _Nonnull(NSURLConnection * _Nonnull connection, NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull redirectResponse) {
        if (redirectResponse) {
            numberOfRedirects++;
        }
        return request;
    }];
    
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(numberOfRedirects).will.equal(5);
}

#pragma mark - Pause
- (void)testThatOperationCanBePaused{
    [Expecta setAsynchronousTestTimeout:3.0];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/delay/1" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation start];
    expect([operation isExecuting]).will.beTruthy();
    
    [operation pause];
    expect([operation isPaused]).will.beTruthy();
    [operation cancel];
}

- (void)testThatPausedOperationCanbeResumed{
    [Expecta setAsynchronousTestTimeout:3.0];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/delay/1" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation start];
    expect([operation isExecuting]).will.beTruthy();
    [operation pause];
    expect([operation isPaused]).will.beTruthy();
    [operation resume];
    expect([operation isExecuting]).will.beTruthy();
    
    [operation cancel];
    
}

- (void)testThatPausedOperationCanbeCompleted {
    [Expecta setAsynchronousTestTimeout:3.0];
    __block id blockResponseObject = nil;
    __block id blockError = nil;
    
    NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/delay/1" relativeToURL:self.baseAFURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:requset];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        blockResponseObject = responseObject;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    expect([operation isExecuting]).will.beTruthy();
    [operation pause];
    expect([operation isPaused]).will.beTruthy();
    [operation resume];
    expect([operation isExecuting]).will.beTruthy();
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(blockResponseObject).willNot.beNil();
}

- (void)testThatOperationPostsDidStartNotificationWhenStarted {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/design" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operatioin = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __block BOOL notificationFound;
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingOperationDidStartNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([[[note object] request] isEqual:operatioin.request]) {
            notificationFound = YES;
        }
    }];
    
    [operatioin start];
    expect(notificationFound).will.beTruthy();
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)testThatOperationPostsDidFinishNotificationWhenFinished {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/design" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __block BOOL notificationFound;
    
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingOperationDidFinishNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([[[note object] request] isEqual:operation.request]) {
            notificationFound = YES;
        }
    }];
    
    [operation start];
    expect(notificationFound).will.beTruthy();
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

- (void)testThatCompletionBlockForBatchRequestsIsFiredAfterAllOperationCompletionBlocks {
    __block BOOL firstBlock = NO;
    __block BOOL secondBlock = NO;
    __block id firstBlockError = nil;
    __block id secondBlockError = nil;
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/design" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request1];
    [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        firstBlock = YES;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        firstBlockError = error;
    }];
    
    NSURLRequest *reqeust2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/design" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:reqeust2];
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        secondBlock = YES;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        secondBlockError = error;
    }];
    
    __block BOOL completioinBlockFiredAfterOtherBlocks = NO;
    NSArray *batchRequests = [AFURLConnectionOperation batchOfRequestOperations:@[operation1, operation2] progressBlock:nil completionBlock:^(NSArray * _Nonnull operations) {
        if (firstBlock && secondBlock) {
            completioinBlockFiredAfterOtherBlocks = YES;
        }
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperations:batchRequests waitUntilFinished:NO];
    
    expect(firstBlockError).will.beNil();
    expect(secondBlockError).will.beNil();
    expect(completioinBlockFiredAfterOtherBlocks).will.beTruthy();
}

- (void)testThatOperationInvokesFailureCompletionBlockWithErrorOnWritingStreamFailure{
    __block NSError *blockError;
    NSURLRequest *reqeust = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/design" relativeToURL:self.baseURL]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:reqeust];
    NSError *streamError = [NSError errorWithDomain:NSStreamSocketSSLErrorDomain code:0 userInfo:nil];
    
    [operation setOutputStream:({
//        id mockStream = [OCMockObject mockForClass:[NSOutputStream class]];
//        [[[mockStream stub] andReturn:streamError] streamError];
        //mock一个NSOutputStream
        id mockStream = OCMStrictClassMock([NSOutputStream class]);
        //stub StreamError方法，返回streamError
        OCMStub([mockStream streamError]).andReturn(streamError);
        BOOL no = NO;
//        [[[mockStream stub] andReturnValue:OCMOCK_VALUE(no)]hasSpaceAvailable];
        OCMStub([mockStream hasSpaceAvailable]).andReturn(no);
        [[mockStream stub] scheduleInRunLoop:OCMOCK_ANY forMode:OCMOCK_ANY];
        [[mockStream stub] open]; 
        [[mockStream stub] close];
        
        mockStream;
    })];
    
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.equal(streamError);
}

- (void)testThatOperationInvokesSuccessCompletionBlockForHTTPSRequest{
    __block id blockResponseObject = nil;
    __block id blockError = nil;
//    NSURL *baseDownloadURL = [NSURL URLWithString:@"http://app.billionscatalog.net/download/"];
//    NSURL *secureBaseURL = [NSURL URLWithString:[baseDownloadURL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
    NSURL *secureBaseURL = [NSURL URLWithString:[self.baseAFURL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:secureBaseURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        blockResponseObject = responseObject;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        blockError = error;
    }];
    
    [operation start];
    expect([operation isFinished]).will.beTruthy();
    expect(blockError).will.beNil();
    expect(blockResponseObject).willNot.beNil();
}


@end

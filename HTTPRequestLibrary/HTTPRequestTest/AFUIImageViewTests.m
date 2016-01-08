//
//  AFUIImageViewTests.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/28.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//
#import "AFTestCase.h"
#import "UIImageView+AFNetworking.h"

@interface AFUIImageViewTests : AFTestCase
@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, strong) NSURLRequest *cachedImageRequest;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation AFUIImageViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.imageView = [UIImageView new];
    [self setUpSharedImageCache];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self tearDownSharedImageCache];
    [super tearDown];
}


- (void)setUpSharedImageCache {
    NSString *resourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *imagePath = [resourcePath stringByAppendingPathComponent:@"Icon.png"];
    self.cachedImage = [UIImage imageWithContentsOfFile:imagePath];
    self.cachedImageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://foo.bar/image"]];
    
    id<AFImageCache> mockImageCache = [OCMockObject mockForProtocol:@protocol(AFImageCache)];
    [[[(OCMockObject *)mockImageCache stub] andReturn:self.cachedImage] cachedImageForRequest:self.cachedImageRequest];
    [UIImageView setSharedImageCache:mockImageCache];
}

- (void)tearDownSharedImageCache {
    [UIImageView setSharedImageCache:nil];
}

- (void)testSetImageWithURLRequestUsesCachedImage {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Image view uses cached image"];
    typeof(self) __weak weakSelf = self;
    [self.imageView
     setImageWithURLRequest:self.cachedImageRequest
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         XCTAssertEqual(request, weakSelf.cachedImageRequest, @"URL requests do not match");
         XCTAssertNil(response, @"Response should be nil when image is returned from cache");
         XCTAssertEqual(image, weakSelf.cachedImage, @"Cached images do not match");
         [expectation fulfill];
     }
     failure:nil];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error) {
        
    }];
}
@end

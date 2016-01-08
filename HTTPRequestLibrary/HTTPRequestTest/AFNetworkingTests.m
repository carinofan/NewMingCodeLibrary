//
//  AFNetworkingTests.m
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/28.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "AFNetworkingTests.h"

NSString * const AFNetworkingTestsBaseURLString = @"http://httpbin.org/";

@implementation AFNetworkingTests

+ (void)load {
    if ([[[[[NSProcessInfo processInfo] environment] valueForKey:@"AFTestsLoggingEnabled"] uppercaseString] isEqualToString:@"YES"]) {
        
    }
}

@end

//
//  HTTPRequestManager.h
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/22.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "HttpRequestOperation.h"

@interface HTTPRequestManager : NSObject

+ (instancetype)manager;

@property (assign, nonatomic)BOOL supportHttps;
@property (assign, nonatomic)NSTimeInterval timerOutInterval;

- (HttpRequestOperation *)PostXml:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure;

- (HttpRequestOperation *)Head:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure;

@end

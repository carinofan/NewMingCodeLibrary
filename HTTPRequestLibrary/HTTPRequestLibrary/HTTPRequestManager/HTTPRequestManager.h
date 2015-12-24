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
#import "HTTPRequestDataModel.h"

@interface HTTPRequestManager : NSObject

+ (instancetype)manager;

- (HttpRequestOperation *)PostXml:(HTTPRequestDataModel *)dataModel success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure;

- (HttpRequestOperation *)Head:(HTTPRequestDataModel *)dataModel success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure;

- (HttpRequestOperation *)PostDownload:(HTTPRequestDownload *)dataModel success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure;

- (HttpRequestOperation *)PostUpload:(HTTPRequestUpload *)dataModel success:(void (^)(id responseObject))success failure:(void (^)(id responseObject, NSError *error))failure;
@end

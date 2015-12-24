//
//  HTTPRequestDataModel.h
//  HTTPRequestLibrary
//
//  Created by Fanming on 15/12/23.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPRequestDataModel : NSObject

@property (copy, nonatomic)NSString *baseString;
@property (copy, nonatomic)NSDictionary *parameters;
@property (assign, nonatomic)BOOL supportHttps;
@property (assign, nonatomic)NSTimeInterval timerOutInterval;

@end

@interface HTTPRequestDownload : HTTPRequestDataModel

@property (copy, nonatomic) NSString *subPath;
@property (copy, nonatomic) NSString *fileName;
@property (assign, nonatomic) NSString *rangeBytes;

@end

@interface HTTPRequestUpload : HTTPRequestDataModel

@property (strong, nonatomic)NSData *uploadData;
@property (copy, nonatomic)NSString *fileName;
@property (copy, nonatomic)NSString *fileType;

@end
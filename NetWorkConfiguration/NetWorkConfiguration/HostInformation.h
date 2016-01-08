//
//  HostInformation.h
//  SunnyGirl
//
//  Created by Fanming on 15/6/29.
//  Copyright (c) 2015年 FanMing. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const key_code_Host_Address;
extern NSString *const key_code_Host_Interface;
extern NSString *const key_code_Host_FilePath;
extern NSString *const key_code_Host_TransportProtocol;
extern NSString *const key_code_Host_pingSuccess;
extern NSString *const key_code_Host_requestFailed;
extern NSString *const key_code_Host_statusCodeSuccess;

@interface HostInformation : NSObject<NSCoding>

@property(nonatomic, strong)NSString *host;
@property(nonatomic, strong)NSString *hostAddress;
@property(nonatomic, strong)NSString *hostInterface;
@property(nonatomic, strong)NSString *transportProtocol;
@property(nonatomic, assign)BOOL pingSuccess;
@property(nonatomic, assign)BOOL requestFailed;

-(NSString *)completeHostInformationDataWithHost:(HostInformation *)host;

@end


@interface HttpHostInformation : HostInformation

@property(nonatomic, strong)NSString *hostFilepath;
@property(nonatomic, assign)BOOL statusCodeSuccess;

-(NSString *)completeHttpHostInformationDataWithHost:(HttpHostInformation *)host;

-(NSString *)completeHttpsHostInformationDataWithHost:(HttpHostInformation *)host;

@end
//
//  HostInformation.m
//  SunnyGirl
//
//  Created by Fanming on 15/6/29.
//  Copyright (c) 2015年 FanMing. All rights reserved.
//

#import "HostInformation.h"

NSString *const key_code_Host_Address = @"key_code_Host_Address";
NSString *const key_code_Host_Interface = @"key_code_Host_Interface";
NSString *const key_code_Host_FilePath = @"key_code_Host_FilePath";
NSString *const key_code_Host_TransportProtocol = @"key_code_Host_TransportProtocol";
NSString *const key_code_Host_pingSuccess = @"key_code_Host_pingSuccess";
NSString *const key_code_Host_requestFailed = @"key_code_Host_requestFailed";
NSString *const key_code_Host_statusCodeSuccess = @"key_code_Host_statusCodeSuccess";

@implementation HostInformation

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.hostAddress forKey:key_code_Host_Address];
    [aCoder encodeObject:self.hostInterface forKey:key_code_Host_Interface];
    [aCoder encodeObject:self.transportProtocol forKey:key_code_Host_TransportProtocol];
    [aCoder encodeBool:self.pingSuccess forKey:key_code_Host_pingSuccess];
    [aCoder encodeBool:self.requestFailed forKey:key_code_Host_requestFailed];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.hostAddress = [aDecoder decodeObjectForKey:key_code_Host_Address];
        self.hostInterface = [aDecoder decodeObjectForKey:key_code_Host_Interface];
        self.transportProtocol = [aDecoder decodeObjectForKey:key_code_Host_TransportProtocol];
        self.pingSuccess = [aDecoder decodeBoolForKey:key_code_Host_pingSuccess];
        self.requestFailed = [aDecoder decodeBoolForKey:key_code_Host_requestFailed];
    }
    return self;
}

-(NSString *)completeHostInformationDataWithHost:(HostInformation *)host{
    NSString *hostString = [NSString stringWithFormat:@"%@:%@",host.hostAddress,host.hostInterface];
    return hostString;
}

-(NSString*)host{
    return [self completeHostInformationDataWithHost:self];
}

@end

@implementation HttpHostInformation

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.hostFilepath forKey:key_code_Host_FilePath];
    [aCoder encodeBool:self.statusCodeSuccess forKey:key_code_Host_statusCodeSuccess];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hostFilepath = [aDecoder decodeObjectForKey:key_code_Host_FilePath];
        self.statusCodeSuccess = [aDecoder decodeBoolForKey:key_code_Host_statusCodeSuccess];
    }
    return self;
}

-(NSString *)completeHttpHostInformationDataWithHost:(HttpHostInformation *)host{
    NSString *hostString = [NSString stringWithFormat:@"http://%@:%@/%@/",host.hostAddress,host.hostInterface,host.hostFilepath];
    return hostString;
}

- (NSString *)completeHttpsHostInformationDataWithHost:(HttpHostInformation *)host{
    NSString *hostString = [NSString stringWithFormat:@"https://%@:%@/%@/",host.hostAddress,host.hostInterface,host.hostFilepath];
    return hostString;
}

-(NSString*)host{
    return [self completeHttpHostInformationDataWithHost:self];
}

@end

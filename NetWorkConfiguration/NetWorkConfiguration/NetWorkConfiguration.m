//
//  NetWorkConfiguration.m
//  NetWorkConfiguration
//
//  Created by Fanming on 15/12/24.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "NetWorkConfiguration.h"
#import "HTTPRequestManager.h"
#import "NSXMLElement+XMPP.h"
#import "HostInformation.h"

NSString * const host_Local_Plist_Path = @"HostList_1.0.plist";

NSString * const httpHostDefineInPlist = @"http://192.168.2.210:9092/http/";
NSString * const xmppHostInPlist = @"192.168.2.210:5225";
NSString * const sipListDefine = @"192.168.3.118:5060";

//域名列表
NSString * const hostNameInPlist = @"https://itech.billionscatalog.net/getservers/?Ver=6";
NSString * const hostName2InPlist = @"https://itech-i.billionscatalog.net/getservers/?Ver=6";
NSString * const hostName3InPlist = @"https://itech.billioncatalog.net/getservers/?Ver=6";
NSString * const hostName4InPlist = @"https://itech-i.billioncatalog.net/getservers/?Ver=6";
NSString * const hostName5InPlist = @"http://58.64.196.103/getservers/?Ver=6";
NSString * const hostName6InPlist = @"http://121.46.0.14/getservers/?Ver=6";

NSString * const key_DomainList = @"HostManager_key_DomainList";
NSString * const key_HttpHostList = @"HostManager_key_HttpHostList";
NSString * const key_XmppHostList = @"HostManager_key_XmppHostList";
NSString * const key_SipHostList = @"HostManager_key_SipHostList";
NSString * const key_HttpsHostList = @"HostManager_key_HttpsHostList";
NSString * const key_CDNHostList = @"HostManager_key_CDNHostList";

NSString * const key_currcentDoMain = @"HostManager_key_currcentDoMain";
NSString * const key_currcentHttpHost = @"HostManager_key_currcentHttpHost";
NSString * const key_currcentHttpPort = @"HostManager_key_currcentHttpPort";
NSString * const key_currcentHttpsHost = @"HostManager_key_currcentHttpsHost";
NSString * const key_currcentHttpsPort = @"HostManager_key_currcentHttpsPort";
NSString * const key_currcentXmppHost = @"HostManger_key_currcentXmppHost";
NSString * const key_currcentXmppPort = @"HostManger_key_currcentXmppPort";
NSString * const key_currcentSipListString = @"HostMagaer_key_currcentSipListString";

@interface NetWorkConfiguration ()

@property (strong, nonatomic)Reachability *reachability;
@property (copy, nonatomic)NSDictionary *networkConfigList;
@property (copy, nonatomic)NSMutableArray *domain_List;
@property (copy, nonatomic)NSMutableArray *domainSuccessList;
@property (copy, nonatomic)NSMutableArray *domainErrorList;
@property (copy, nonatomic)NSMutableArray *domainFailedList;

@property (copy, nonatomic)NSString *currcentDoMain;
@property (copy, nonatomic)NSString *currcentHTTPHost;
@property (copy, nonatomic)NSString *currcentHTTPSHost;
@property (copy, nonatomic)NSString *currcentXMPPHost;
@property (copy, nonatomic)NSString *currcentSipHost;
@property (copy, nonatomic)NSString *currcentCDNHost;

@end

@implementation NetWorkConfiguration

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initialiseNetworkConfiguration];
        self.reachability = [[Reachability alloc] init];
    }
    return self;
}

//根据subPath返回程序Document目录下该subPath的路径
- (NSString *)docPathWithSubPath:(NSString *)subPath {
    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (nil==subPath) {
        return docPath;
    } else {
        NSString *path=[docPath stringByAppendingPathComponent:subPath];
        return path;
    }
}

-(BOOL)saveFileWithDic:(NSMutableDictionary *)dictionary{
    NSString * path = [self docPathWithSubPath:host_Local_Plist_Path];
    _networkConfigList = dictionary;
    BOOL result = [dictionary writeToFile:path atomically:YES];
    return result;
}

-(NSDictionary *)networkConfigPlistFromPath{
    NSString * path = [self docPathWithSubPath:host_Local_Plist_Path];
    _networkConfigList = [NSDictionary dictionaryWithContentsOfFile:path];
    return self.networkConfigList;
}

- (void)initialiseNetworkConfiguration{
    self.networkConfigList = [self networkConfigPlistFromPath];
    NSMutableDictionary * newDictionary = [NSMutableDictionary dictionaryWithDictionary:self.networkConfigList];
    NSMutableArray * hostNameList = [newDictionary objectForKey:key_DomainList];
    hostNameList = [NSMutableArray array];
    [hostNameList addObject:hostNameInPlist];
    [hostNameList addObject:hostName2InPlist];
    [hostNameList addObject:hostName3InPlist];
    [hostNameList addObject:hostName4InPlist];
    [hostNameList addObject:hostName5InPlist];
    [hostNameList addObject:hostName6InPlist];
    [newDictionary setObject:hostNameList forKey:key_DomainList];
    
    [self saveFileWithDic:newDictionary];
    
}

- (void)beginDoMainHostConfiguration{
    _domainSuccessList = [NSMutableArray array];
    _domainErrorList = [NSMutableArray array];
    _domainFailedList = [NSMutableArray array];
    self.currcentDoMain = hostNameInPlist;
    [self requestHostIpListFromeHostName:hostNameInPlist];
    [self judgedAllDomainNameFromDomainNameList];
}

//异步获取所有域名的连通性判断
-(void)judgedAllDomainNameFromDomainNameList{
    NSArray *domainNameList = [self domainNameListInPlist];
    _domain_List = [NSMutableArray array];
    for (NSInteger i = 0; i < domainNameList.count; i++) {
        NSString *domainName = [domainNameList objectAtIndex:i];
        //通过获取httpRequestStatuscode判断主机地连通性
        [self requestHttpStatusCodeWithUrl:domainName];
        NSString *addressInDomainName = [self selectDomainHostFromDomainName:domainName];
        [self.domain_List addObject:addressInDomainName];
        //通过ping的方法判断主机的连通性
        [self hostReachabilityWithPing:addressInDomainName];
    }
}

-(void)hostReachabilityWithPing:(NSString *)host{
    [self.reachability getHostReachability:host target:self sel:@selector(pingOnceResult::)];
}

- (void)pingOnceResult:(NSNumber*)success :(id)ping_instance{
    NSString *urlString = [ping_instance getTargetHost];
    NSLog(@"ping Result = %d url = %@",success.boolValue,urlString);
    [self hostReachabilityControlWithHost:urlString andReachability:success.boolValue];
}

-(void)hostReachabilityControlWithHost:(NSString *)host andReachability:(BOOL)result{
    NSUInteger domainIndex = [self.domain_List indexOfObject:host];
    NSArray *domainList = [self domainNameListInPlist];
    NSString *domainName = [domainList objectAtIndex:domainIndex];
    [self resultFromDomainReachabilityJudgedWithDomainHost:domainName andResult:result];
}
#pragma mark -
#pragma mark url与主机拆分与拼接
/**
 *  根据既定域名地址匹配出域名主机
 *
 *  @param everyString @“http://itech.billionscatalog.net/servers/?Ver=4”
 *
 *  @return 域名@“itech.billionscatalog.net”
 */
-(NSString *)selectDomainHostFromDomainName:(NSString *)everyString{
    NSString * beginString = @"://";
    NSString * endString = @"/";
    NSRange range1 = [everyString rangeOfString:beginString];
    everyString = [everyString substringFromIndex:range1.location + range1.length];
    NSRange range2 = [everyString rangeOfString:endString];
    everyString = [everyString substringToIndex:range2.location];
    return everyString;
}

#pragma mark -
#pragma mark 网络连通性判断
-(void)requestHttpStatusCodeWithUrl:(NSString *)urlString{
    HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
    data.baseString = urlString;
    data.parameters = nil;
    if ([urlString isEqualToString:hostNameInPlist] || [urlString isEqualToString:hostName2InPlist] || [urlString isEqualToString:hostName3InPlist] || [urlString isEqualToString:hostName4InPlist]) {
        data.supportHttps = YES;
    }else{
        data.supportHttps = NO;
    }
    HTTPRequestManager *manager = [HTTPRequestManager manager];
    [manager Head:data success:^(id responseObject) {
        NSHTTPURLResponse *response = responseObject;
        NSInteger statusCode = (long)[response statusCode];
        if (statusCode == 200) {
            [self resultFromDomainReachabilityJudgedWithDomainHost:urlString andResult:YES];
        }else{
            [self resultFromDomainReachabilityJudgedWithDomainHost:urlString andResult:NO];
        }
        
        
    } failure:^(id responseObject, NSError *error) {
        [self resultFromDomainReachabilityJudgedWithDomainHost:urlString andResult:NO];
    }];
    
}

-(void)resultFromDomainReachabilityJudgedWithDomainHost:(NSString *)domainString andResult:(BOOL)result{
    if (result && ([self.domainFailedList indexOfObject:domainString] == NSNotFound)) {
        [self.domainSuccessList addObject:domainString];
    }else{
        if ([self.domainSuccessList indexOfObject:domainString] != NSNotFound) {
            [self.domainSuccessList removeObject:domainString];
        }
        
        if ([self.domainErrorList indexOfObject:domainString] == NSNotFound) {
            [self.domainErrorList addObject:domainString];
        }else{
            [self.domainFailedList addObject:domainString];
        }
    }
    if ([self.domainFailedList indexOfObject:self.currcentDoMain] != NSNotFound) {
        [self requestHostListWithDomainControl];
    }
}

-(void)requestHostListWithDomainControl{
    NSArray *domainNameList = [self domainNameListInPlist];
    NSInteger currcent = [domainNameList indexOfObject:self.currcentDoMain];
    
    if (self.domainFailedList.count >= domainNameList.count) {
        
        return;
    }
    
    for (NSInteger i = currcent + 1; i < [domainNameList count]; i++) {
        NSString *domain = [domainNameList objectAtIndex:i];
        if ([self.domainSuccessList indexOfObject:domain] != NSNotFound) {
            self.currcentDoMain = domain;
            [self setCurrcentDomainNameToPlist];
            i = domainNameList.count;
        }
    }
}

/**
 *  设置当前使用域名并保存
 */
-(void)setCurrcentDomainNameToPlist{
    self.networkConfigList = [self networkConfigPlistFromPath];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:self.networkConfigList];
    [dictionary setObject:self.currcentDoMain forKey:key_currcentDoMain];
    BOOL result = [self saveFileWithDic:dictionary];
    if (result) {
        //开始请求域名主机列表
        [self requestHostIpListFromeHostName:self.currcentDoMain];
    }
}

-(void)requestHostIpListFromeHostName:(NSString *)hostName{
    if (hostName.length > 0) {
        hostName = [hostName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        HTTPRequestDataModel *data = [[HTTPRequestDataModel alloc]init];
        data.baseString = hostName;
        data.parameters = nil;
        if ([hostName isEqualToString:hostNameInPlist] || [hostName isEqualToString:hostName2InPlist] || [hostName isEqualToString:hostName3InPlist] || [hostName isEqualToString:hostName4InPlist]) {
            data.supportHttps = YES;
        }else{
            data.supportHttps = NO;
        }
        HTTPRequestManager *manager = [HTTPRequestManager manager];
        [manager PostXml:data success:^(id responseObject) {
            NSString * xmlDoc = responseObject;
            NSXMLElement * xmlElement = [[NSXMLElement alloc]initWithXMLString:xmlDoc error:nil];
            NSArray * messageArray = [xmlElement nodesForXPath:@"//mes" error:nil];
            NSMutableDictionary * hostInformationDic = [NSMutableDictionary dictionary];
            for(NSXMLElement * element in messageArray){
                NSArray * ipAddressArray = [element elementsForName:@"els"];
                for(NSXMLElement * elementForIp in ipAddressArray){
                    NSArray * ipAddress = [elementForIp elementsForName:@"interfaces"];
                    for(NSXMLElement * elementForInterface in ipAddress){
                        int hostInterface_Type = [[[elementForInterface attributeForName:@"type"]stringValue]intValue];
                        NSArray * interfaceArray = [elementForInterface elementsForName:@"interface"];
                        NSMutableArray * interfacelist = [NSMutableArray array];
                        switch (hostInterface_Type) {
                            case 0:
                            {
                                for (int i = 0; i < interfaceArray.count; i++) {
                                    NSXMLElement * element_ip = [interfaceArray objectAtIndex:i];
                                    HttpHostInformation *host = [self httpHostInformationWithXml:element_ip];
                                    host.transportProtocol = @"http";
                                    NSData *hostData = [NSKeyedArchiver archivedDataWithRootObject:host];
                                    [interfacelist addObject:hostData];
                                }
                                [hostInformationDic setObject:interfacelist forKey:key_HttpHostList];
                            }
                                break;
                            case 1:
                            {
                                for (int i = 0; i < interfaceArray.count; i++) {
                                    NSXMLElement * element_ip = [interfaceArray objectAtIndex:i];
                                    HostInformation *host = [self hostInformationWithXml:element_ip];
                                    host.transportProtocol = @"xmpp";
                                    NSData *hostData = [NSKeyedArchiver archivedDataWithRootObject:host];
                                    [interfacelist addObject:hostData];
                                }
                                [hostInformationDic setObject:interfacelist forKey:key_XmppHostList];
                            }
                                break;
                            case 2:{
                                for (int i = 0; i < interfaceArray.count; i++) {
                                    NSXMLElement * element_ip = [interfaceArray objectAtIndex:i];
                                    HostInformation *host = [self hostInformationWithXml:element_ip];
                                    host.transportProtocol = [[elementForInterface attributeForName:@"dataTransportProtocol"]stringValue];
                                    NSData *hostData = [NSKeyedArchiver archivedDataWithRootObject:host];
                                    [interfacelist addObject:hostData];
                                }
                                [hostInformationDic setObject:interfacelist forKey:key_SipHostList];
                                
                            }
                                break;
                            case 3:{
                                for (int i = 0; i < interfaceArray.count; i++) {
                                    NSXMLElement * element_ip = [interfaceArray objectAtIndex:i];
                                    HttpHostInformation *host = [self httpHostInformationWithXml:element_ip];
                                    host.transportProtocol = @"https";
                                    NSData *hostData = [NSKeyedArchiver archivedDataWithRootObject:host];
                                    [interfacelist addObject:hostData];
                                }
                                [hostInformationDic setObject:interfacelist forKey:key_HttpsHostList];
                            }
                                break;
                            case 4:{
                                for (int i = 0; i < interfaceArray.count; i++) {
                                    NSXMLElement * element_ip = [interfaceArray objectAtIndex:i];
                                    HttpHostInformation *host = [self httpHostInformationWithXml:element_ip];
                                    host.transportProtocol = @"cdn";
                                    NSData *hostData = [NSKeyedArchiver archivedDataWithRootObject:host];
                                    [interfacelist addObject:hostData];
                                }
                                [hostInformationDic setObject:interfacelist forKey:key_CDNHostList];
                            }
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
            }
            [self configNetWorkDataWithHostlist:hostInformationDic];
        } failure:^(id responseObject, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

-(HttpHostInformation *)httpHostInformationWithXml:(NSXMLElement *)element_ip{
    HttpHostInformation *host = [[HttpHostInformation alloc]init];
    host.hostAddress = [element_ip stringValue];
    host.hostInterface = [[element_ip attributeForName:@"port"]stringValue];
    host.hostFilepath = [[element_ip attributeForName:@"endwith"] stringValue];
    return host;
}

-(HostInformation *)hostInformationWithXml:(NSXMLElement *)element_ip{
    HostInformation *host = [[HttpHostInformation alloc]init];
    host.hostAddress = [element_ip stringValue];
    host.hostInterface = [[element_ip attributeForName:@"port"]stringValue];
    return host;
}

-(void)configNetWorkDataWithHostlist:(NSMutableDictionary *)hostDic{
    self.networkConfigList = [self networkConfigPlistFromPath];
    NSMutableDictionary * newDictionary = [NSMutableDictionary dictionaryWithDictionary:self.networkConfigList];
    NSMutableArray *httpHostList = [hostDic objectForKey:key_HttpHostList];
    NSMutableArray *xmppHostList = [hostDic objectForKey:key_XmppHostList];
    NSMutableArray *sipHostList = [hostDic objectForKey:key_SipHostList];
    NSMutableArray *httpsHostList = [hostDic objectForKey:key_HttpsHostList];
    NSMutableArray *cdnHostList = [hostDic objectForKey:key_CDNHostList];
    if (httpHostList.count > 0) {
        [newDictionary setObject:httpHostList forKey:key_HttpHostList];
        HttpHostInformation *information = [NSKeyedUnarchiver unarchiveObjectWithData:[httpHostList objectAtIndex:0]];
        [newDictionary setObject:[information completeHttpHostInformationDataWithHost:information] forKey:key_currcentHttpHost];
        [newDictionary setObject:information.hostInterface forKey:key_currcentHttpPort];
    }
    
    if (xmppHostList.count > 0) {
        [newDictionary setObject:xmppHostList forKey:key_XmppHostList];
        HostInformation *information = [NSKeyedUnarchiver unarchiveObjectWithData:[xmppHostList objectAtIndex:0]];
        [newDictionary setObject:information.hostAddress forKey:key_currcentXmppHost];
        [newDictionary setObject:information.hostInterface forKey:key_currcentXmppPort];
    }
    
    if ([sipHostList count] > 0) {
        [newDictionary setObject:sipHostList forKey:key_SipHostList];
        NSMutableString *sipString = [NSMutableString string];
        for (NSInteger i = 0; i < sipHostList.count; i++) {
            HostInformation *host = [NSKeyedUnarchiver unarchiveObjectWithData:[sipHostList objectAtIndex:i]];
            if (sipString.length == 0) {
                [sipString appendString:[host completeHostInformationDataWithHost:host]];
            }else{
                [sipString appendFormat:@"%@",[NSString stringWithFormat:@",%@",[host completeHostInformationDataWithHost:host]]];
            }
        }
        if (sipString.length > 0) {
            [newDictionary setObject:sipString forKey:key_currcentSipListString];
        }
    }
    
    if ([httpsHostList count] > 0) {
        [newDictionary setObject:httpsHostList forKey:key_HttpsHostList];
        HttpHostInformation *information = [NSKeyedUnarchiver unarchiveObjectWithData:[httpsHostList objectAtIndex:0]];
        [newDictionary setObject:[information completeHttpsHostInformationDataWithHost:information] forKey:key_currcentHttpsHost];
//        NSLog(@"%@",[information completeHttpsHostInformationDataWithHost:information]);
        [newDictionary setObject:information.hostInterface forKey:key_currcentHttpsPort];
    }
    
    if ([cdnHostList count] > 0) {
        [newDictionary setObject:cdnHostList forKey:key_CDNHostList];
#warning CDN暂不支持
    }
    self.networkConfigList = newDictionary;
    BOOL result = [self saveFileWithDic:newDictionary];
    if (result) {
        //网络配置结束
        if (_networkConfigurationResult) {
            _networkConfigurationResult(YES);
        }
    }
}

-(NSArray *)domainNameListInPlist{
    self.networkConfigList = [self networkConfigPlistFromPath];
    return [self.networkConfigList objectForKey:key_DomainList];
}

- (NSString *)currcentHTTPInterface{
    return [self.networkConfigList objectForKey:key_currcentHttpHost];
}

- (NSString *)currcentHTTPPort{
    return [self.networkConfigList objectForKey:key_currcentHttpPort];
}

- (NSString *)currcentHTTPSInterface{
    return [self.networkConfigList objectForKey:key_currcentHttpHost];
    
}

- (NSString *)currcentHTTPSPort{
    return [self.networkConfigList objectForKey:key_currcentHttpsPort];
    
}

- (NSString *)currcentXMPPHost{
    return [self.networkConfigList objectForKey:key_currcentXmppHost];
}

- (NSString *)currcentXMPPPort{
    return [self.networkConfigList objectForKey:key_currcentXmppPort];
}

- (NSString *)currcentSipListString{
    return [self.networkConfigList objectForKey:key_currcentSipListString];
}


@end

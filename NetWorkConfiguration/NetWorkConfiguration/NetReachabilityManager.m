//
//  NetReachabilityManager.m
//  NetWorkConfiguration
//
//  Created by Fanming on 15/12/25.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import "NetReachabilityManager.h"

@interface NetReachabilityManager ()

@property (strong, nonatomic) Reachability *reachability;
@property (copy, nonatomic) NSMutableArray *networkBlockList;
@property (assign, nonatomic) NetworkStatus networkStatus;
@property (assign, nonatomic) BOOL configurationResult;

@end

@implementation NetReachabilityManager

-(id)init{
    if (self = [super init]) {
        //网络数据配置
        _networkConfig = [[NetWorkConfiguration alloc]init];
        _networkStatus = NotReachable;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kRouterReachabilityChangedNotification object:nil];
        //初始化网络监控
        _reachability = [Reachability sharedReachability];
        [self.reachability startNotifier];
        
    }
    return self;
}

+(NetReachabilityManager *)sharedManager{
    static NetReachabilityManager *netReachabilityManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        netReachabilityManager = [[self alloc]init];
    });
    return netReachabilityManager;
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

-(void)updateInterfaceWithReachability:(Reachability *)reach{
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    self.networkStatus = netStatus;
    self.configurationResult = NO;
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"无网络连接");
            [self withoutNetworkStatusConfiguation];
        }
            break;
            
        case ReachableViaWWAN:
        {
            NSLog(@"当前处于WWan网络");
            [self beNetworkStatusConfiguation];
        }
            break;
        case ReachableViaWiFi:
        {
            NSLog(@"当前处于WiFi网络");
            [self beNetworkStatusConfiguation];
        }
            break;
        case ReachableViaVPN:{
            NSLog(@"当前连接VPN");
            [self beNetworkStatusConfiguation];
        }
            break;
        default:
            break;
    }
}

- (void)setNetworkStatus:(NetworkStatus)networkStatus{
    if (_networkStatus != networkStatus) {
        _networkStatus = networkStatus;
        if (_networkReachabilityConfiguration) {
            self.networkReachabilityConfiguration(self.networkStatus, NO);
        }
    }
}

#pragma mark -
#pragma mark 网络配置
-(void)withoutNetworkStatusConfiguation{
    _networkConfig = nil;
    _networkConfig = [[NetWorkConfiguration alloc]init];
}

-(void)beNetworkStatusConfiguation{
    _networkConfig = nil;
    _networkConfig = [[NetWorkConfiguration alloc]init];
    __weak NetReachabilityManager *weakself = self;
    _networkConfig.networkConfigurationResult = ^(BOOL result){
        weakself.configurationResult = YES;
        if (weakself.networkReachabilityConfiguration) {
            weakself.networkReachabilityConfiguration(weakself.networkStatus, YES);
        }
    };
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self.networkConfig selector:@selector(beginDoMainHostConfiguration) userInfo:nil repeats:NO];
}

- (void)beginNetworkConfiguratioin:(void (^)(NetworkStatus, BOOL))reachabilityConfiguration{
    reachabilityConfiguration(self.networkStatus, self.configurationResult);
    if (self.networkBlockList.count == 0) {
        _networkBlockList = [NSMutableArray array];
    }
    [self.networkBlockList addObject:reachabilityConfiguration];
    if (self.networkReachabilityConfiguration == nil) {
        NSMutableArray *list = self.networkBlockList;
        self.networkReachabilityConfiguration = ^(NetworkStatus statue, BOOL result){
            for (NSInteger i = 0; i < list.count; i++) {
                void (^networkReachabilityConfiguration)(NetworkStatus statue, BOOL result) = [list objectAtIndex:i];
                networkReachabilityConfiguration(statue, result);
            }
        };
    }
}

@end

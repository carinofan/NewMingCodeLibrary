//
//  NetReachabilityManager.h
//  NetWorkConfiguration
//
//  Created by Fanming on 15/12/25.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "NetWorkConfiguration.h"

@interface NetReachabilityManager : NSObject

@property (strong, nonatomic) NetWorkConfiguration *networkConfig;
@property (copy, nonatomic) void (^networkReachabilityConfiguration)(NetworkStatus statue, BOOL success);

+(NetReachabilityManager *)sharedManager;

- (void)beginNetworkConfiguratioin:(void (^)(NetworkStatus statue, BOOL success))reachabilityConfiguration;

@end

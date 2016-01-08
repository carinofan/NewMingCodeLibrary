//
//  NetWorkConfiguration.h
//  NetWorkConfiguration
//
//  Created by Fanming on 15/12/24.
//  Copyright © 2015年 Guangzhou Ligo Information Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability/Reachability.h"

@interface NetWorkConfiguration : NSObject

@property (copy, nonatomic)void (^networkConfigurationResult)(BOOL result);

- (instancetype)init;

- (void)beginDoMainHostConfiguration;

- (NSString *)currcentHTTPInterface;

- (NSString *)currcentHTTPPort;

- (NSString *)currcentHTTPSInterface;

- (NSString *)currcentHTTPSPort;

- (NSString *)currcentXMPPHost;

- (NSString *)currcentXMPPPort;

- (NSString *)currcentSipListString;

@end

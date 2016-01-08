//
//  SimplePingHelper.h
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

extern NSString *kSimplePingEnterBackgroundNotification;

@interface SimplePingDelegate : NSObject <SimplePingDelegate>

+ (instancetype)ping:targetAddress if_addr:(NSString*)if_addr target:(id)target sel:(SEL)sel;
+ (instancetype)pingOnce:(NSString*)address target:(id)target sel:(SEL)sel;

- (void)go;
- (void)stop;
- (int)getPingSeq;
- (NSString*)getTargetAddr;
- (NSString*)getTargetHost;
- (NSString*)getBindAddr;

@end

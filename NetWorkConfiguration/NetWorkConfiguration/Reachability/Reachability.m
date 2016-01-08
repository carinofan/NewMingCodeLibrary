/*
     File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
  Version: 3.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/socket.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Reachability.h"

//#define __DEBUG

NSString *kRouterReachabilityChangedNotification = @"kRouterReachabilityChangedNotification";
NSString *kHostReachabilityChangedNotification = @"kHostReachabilityChangedNotification";
//NSString *path = [[NSBundle mainBundle] pathForResource:@"ring" ofType:@"wav"];

#pragma mark - Supporting functions

#define kShouldPrintReachabilityFlags 1

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    NSLog(@"Reachability: %c%c %c%c%c%c%c%c%c %s\n",
#ifdef TARGET_OS_IPHONE
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
#else
          'X',
#endif
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [Reachability class]], @"info was wrong class in ReachabilityCallback");

    Reachability* noteObject = (__bridge Reachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kRouterReachabilityChangedNotification object:noteObject];
}

#pragma mark - Reachability implementation

@implementation Reachability
singleton_implementation(Reachability)

- (id)init {
    if ((self = [super init])) {
        memset(wifi_ip, '\0', INET_ADDRSTRLEN);
        memset(wwan_ip, '\0', INET_ADDRSTRLEN);
        memset(ppp_ip, '\0', INET_ADDRSTRLEN);
        
        //ping_timer = nil;
        host_state = 0;
        
#ifndef __DEBUG
        root = [NSMutableDictionary dictionary];
        
        int i;
        for (i = 0; i < 5; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"" forKey:@"ip"];
            [dic setObject:@"" forKey:@"delay"];
            [dic setObject:@"" forKey:@"upload"];
            [dic setObject:@"" forKey:@"download"];
            [dic setObject:@"" forKey:@"pkg_lost"];
        
            [root setObject:dic forKey:[NSString stringWithFormat:@"SERVER %d",i]];
            //NSLog(@"%@",root);
        }
        path = [NSHomeDirectory() stringByAppendingString:@"/Documents/network_statistic.plist"];
        NSLog(@"path: %@", path);
        [root writeToFile:path atomically:NO];
#endif
        
        pinger_once_dic = [NSMutableDictionary dictionary];
    }

    return [self reachabilityForInternetConnection];
}


- (NetworkStatus)currentReachabilityStatus
{
    [self refreshLocalIp];
    
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        if (_alwaysReturnLocalWiFiStatus)
            returnValue = [self localWiFiStatusForFlags:flags];
        else
            returnValue = [self networkStatusForFlags:flags];
    }
    
    return returnValue;
}

/*- (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	Reachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    
	if (reachability != NULL) {
		//returnValue= [[self alloc] init];
        returnValue = self;
		if (returnValue != NULL) {
			returnValue->_reachabilityRef = reachability;
			returnValue->_alwaysReturnLocalWiFiStatus = NO;
		}
	}
	return returnValue;
}*/

- (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
    Reachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);

	if (reachability != NULL) {
		returnValue = self;
		if (returnValue != NULL) {
			returnValue->_reachabilityRef = reachability;
			returnValue->_alwaysReturnLocalWiFiStatus = NO;
		}
	}
    
	return returnValue;
}

- (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self reachabilityWithAddress:&zeroAddress];
}

/*+ (instancetype)reachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	Reachability* returnValue = [self reachabilityWithAddress: &localWifiAddress];
	if (returnValue != NULL)
	{
		returnValue->_alwaysReturnLocalWiFiStatus = YES;
	}
    
	return returnValue;
}*/


#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedHandler:) name:kRouterReachabilityChangedNotification object:nil];
    
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

	if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
			returnValue = YES;
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kRouterReachabilityChangedNotification object:self];
	return returnValue;
}

- (void)stopNotifier
{
	if (_reachabilityRef != NULL)
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kRouterReachabilityChangedNotification];
}

- (void)dealloc
{
	[self stopNotifier];
	if (_reachabilityRef != NULL)
		CFRelease(_reachabilityRef);
}


#pragma mark - Network Flag Handling

- (NetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "localWiFiStatus");
	NetworkStatus returnValue = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
		returnValue = ReachableViaWiFi;
	}
	return returnValue;
}


- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PrintReachabilityFlags(flags, "networkStatus");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// The target host is not reachable.
		return NotReachable;
	}

    NetworkStatus returnValue = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = ReachableViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		/*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
		returnValue = ReachableViaWWAN;
	}
    
    if (strlen(ppp_ip) > 6)
        returnValue = ReachableViaVPN;
    
	return returnValue;
}

- (void)sendBackgroundNotice:(BOOL)bg
{
    NSNumber *type = [NSNumber numberWithInt:(bg==YES?0:1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSimplePingEnterBackgroundNotification object:type];
}

- (void)reachabilityChangedHandler:(NSNotification *)note
{
    [self stopPing];

    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    self.curNetStatus = [curReach currentReachabilityStatus];
    
    if (self.curNetStatus != NotReachable)
        [self startPing:nil sel:nil];
}


#pragma mark - Auxilary functions
- (int)refreshLocalIp
{
    int cnt = 0;
    NSString *if_name, *netmask, *local_ip;
    
    memset(wifi_ip, '\0', INET_ADDRSTRLEN);
    memset(wwan_ip, '\0', INET_ADDRSTRLEN);
    memset(ppp_ip, '\0', INET_ADDRSTRLEN);
 
#ifdef __DEBUG
    struct if_data *data;
#endif
    
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs) == 0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family==AF_INET && (cursor->ifa_flags & IFF_LOOPBACK)==0) {
                if_name = [NSString stringWithUTF8String:cursor->ifa_name];
                netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)cursor->ifa_netmask)->sin_addr)];
                local_ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in*)cursor->ifa_addr)->sin_addr)];

#ifdef TARGET_IPHONE_SIMULATOR
                if (!strcmp(cursor->ifa_name, "en1"))
                    strcpy(wifi_ip, inet_ntoa(((struct sockaddr_in*)cursor->ifa_addr)->sin_addr));
#endif
#ifdef TARGET_OS_IPHONE
                if ([if_name hasPrefix:@"en"])
                    strcpy(wifi_ip, inet_ntoa(((struct sockaddr_in*)cursor->ifa_addr)->sin_addr));
                else if([if_name hasPrefix:@"pdp_ip"])
                    strcpy(wwan_ip, inet_ntoa(((struct sockaddr_in*)cursor->ifa_addr)->sin_addr));
#endif
                else if([if_name hasPrefix:@"ppp"])
                    strcpy(ppp_ip, inet_ntoa(((struct sockaddr_in*)cursor->ifa_addr)->sin_addr));
                
                NSLog(@"%@: %@/%@", if_name, local_ip, netmask);
                cnt++;
            }
#ifdef __DEBUG
            if (cursor->ifa_addr->sa_family == AF_LINK && (cursor->ifa_flags & IFF_LOOPBACK)==0) {
                data = cursor->ifa_data;
                if (data && (!strcmp(cursor->ifa_name, "en0") || !strcmp(cursor->ifa_name, "en1")))
                    NSLog(@"%s:in_%.2fm, out_%.2fm, %.2fk, %.2fk",
                          cursor->ifa_name,
                          (double)data->ifi_ibytes/(1024*1024),
                          (double)data->ifi_obytes/(1024*1024),
                          (double)data->ifi_ipackets/1000,
                          (double)data->ifi_opackets/1000);
            }
#endif
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return cnt;
}


- (void) addRemoteHost:(NSString*)address
{
#ifdef __DEBUG
    [[root objectForKey:@"SERVER 0"] setObject:[NSString stringWithString:address] forKey:@"ip"];
    [root writeToFile:path atomically:NO];
#endif
    
    if (serverList == NULL) {
        serverList = [NSMutableDictionary dictionary];
    } else {
        for (id key in serverList)
            if ([(NSString*)key isEqualToString:address])
                return;
    }

    NSMutableDictionary *node;
    if (_curNetStatus != NotReachable) {
        NSString *if_addr;
        if (strlen(ppp_ip) > 6)
            if_addr = [NSString stringWithUTF8String:ppp_ip];
        else if (strlen(wifi_ip) > 6)
            if_addr = [NSString stringWithUTF8String:wifi_ip];
        else if (strlen(wwan_ip) > 6)
            if_addr = [NSString stringWithUTF8String:wwan_ip];
        else
            if_addr = @"0.0.0.0";
        
        SimplePingDelegate *pinger = [SimplePingDelegate ping:(NSString*)address if_addr:if_addr target:self sel:@selector(pingResult::)];
        node = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                pinger, @"pinger",
                [NSNumber numberWithInt:1], @"retry",
                nil];
    } else
        node = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                [NSNull null], @"pinger",
                nil];

    [serverList setObject:node forKey:address];

//    if (_curNetStatus != NotReachable) {
//        pinger = [SimplePingDelegate ping:(NSString*)address if_addr:if_addr target:self sel:@selector(pingResult::)];
//    }
}

- (BOOL) removeRemoteHostWithAddress:(NSString*)address
{
    if (serverList == NULL || [serverList count] == 0)
        return NO;

    for (id key in serverList) {
        if ([key isEqualToString:address]) {
            SimplePingDelegate *pinger = [serverList objectForKey:@"pinger"];
            if ([pinger isKindOfClass:[SimplePingDelegate class]])
                [pinger stop];
            [serverList removeObjectForKey:address];
            return YES;
        }
    }
    
    return NO;
}

- (int) getServerCnt;
{
    return [serverList count];
}

- (void)pingResult:(NSNumber*)success :(id)ping_instance {
    if (success.boolValue) {
#ifdef __DEBUG
        NSLog(@"ping %@ succeed at seq:%d", [ping_instance getTargetHost], [ping_instance getPingSeq]);
        //self.failed_cnt = 0;
#endif
        if (self.ping_retry)
            self.ping_retry = 0;
        [[serverList objectForKey:[ping_instance getTargetHost]] setObject:[NSNumber numberWithInt:1] forKey:@"retry"];
        
        if (!host_state) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHostReachabilityChangedNotification object:[NSNumber numberWithBool:YES]];
            host_state = 1;
        }
    } else {
#ifdef __DEBUG
        NSLog(@"ping %@ failed at seq:%d", [ping_instance getTargetHost], [ping_instance getPingSeq]);
        self.failed_cnt++;
#endif
        
        self.ping_retry++;
        NSMutableDictionary *node = [serverList objectForKey:[ping_instance getTargetHost]];
        int retry = [[node objectForKey:@"retry"] integerValue];
        [node setObject:[NSNumber numberWithInt:(retry+1)] forKey:@"retry"];
        
        if (self.ping_retry>(serverList.count*3) && retry>4 && host_state) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHostReachabilityChangedNotification object:[NSNumber numberWithBool:NO]];
            host_state = 0;
        }
    }
    
//    if (self.simple_ping.nextSequenceNumber)
//        [[root objectForKey:@"SERVER 0"] setObject:[NSString stringWithFormat:@"%u(ms)", self.simple_ping.totalDealy/self.simple_ping.nextSequenceNumber] forKey:@"delay"];
//    [[root objectForKey:@"SERVER 0"] setObject:[NSString stringWithFormat:@"%d/%d",self.simple_ping.nextSequenceNumber-self.simple_ping.pkgRecved,self.simple_ping.nextSequenceNumber] forKey:@"pkg_lost"];
    
    
  //  [root writeToFile:path atomically:NO];

}

- (void)pingOnceResult:(NSNumber*)success :(id)ping_instance {
#ifdef __DEBUG
    if (success.boolValue) {
        NSLog(@"ping once succeed");
    } else {
        NSLog(@"ping once failed");
    }
#endif
    
    NSString *ping_target = [ping_instance getTargetHost];
    NSMutableDictionary *node = [pinger_once_dic objectForKey:ping_target];
    int cnt = [(NSNumber*)[node objectForKey:@"cnt"] intValue];
    if (!success.boolValue && cnt < 2) {
        [node setObject:[NSNumber numberWithInt:(cnt+1)] forKey:@"cnt"];
        [ping_instance go];
        return;
    }
    
    id target = [node objectForKey:@"target"];
    SEL sel = [(NSValue*)[node objectForKey:@"sel"] pointerValue];
    
    if ((target != nil) && [target respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:sel withObject:success withObject:ping_instance];
#pragma clang diagnostic pop
    }
    
    [ping_instance stop];
    [pinger_once_dic removeObjectForKey:ping_target];
}

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
- (BOOL) startPing:(id)_target sel:(SEL)_sel
{
    if (!serverList || serverList.count == 0)
        return NO;
    
    NSString *if_addr;
    if (strlen(ppp_ip) > 6)
        if_addr = [NSString stringWithUTF8String:ppp_ip];
    else if (strlen(wifi_ip) > 6)
        if_addr = [NSString stringWithUTF8String:wifi_ip];
    else if (strlen(wwan_ip) > 6)
        if_addr = [NSString stringWithUTF8String:wwan_ip];
    else
        if_addr = @"0.0.0.0";
    
    for (id key in serverList) {
        NSMutableDictionary *node = [serverList objectForKey:key];
        SimplePingDelegate *pinger = [SimplePingDelegate ping:(NSString*)key if_addr:if_addr target:self sel:@selector(pingResult::)];
        [node setObject:pinger forKey:@"pinger"];
    }

    return YES;
}

- (void)stopPing
{
    if (serverList && serverList.count) {
        for (id key in serverList) {
            NSMutableDictionary *node = [serverList objectForKey:key];
            
            SimplePingDelegate *pinger = [node objectForKey:@"pinger"];
            if ([pinger isKindOfClass:[SimplePingDelegate class]])
                [pinger stop];
            [node setObject:[NSNull null] forKey:@"pinger"];
        }
    }
}

#pragma mark - Tool functions
- (NSString *)resolveHost:(NSString *)host
{
    int ret;
    char str[INET_ADDRSTRLEN];
    const char *pstr;
    struct addrinfo hint, *head;//, *cur;
    
    bzero(&hint, sizeof(hint));
    hint.ai_family = AF_INET;
    hint.ai_socktype = SOCK_STREAM;
    
    ret = getaddrinfo([host UTF8String], NULL, &hint, &head);
    if (ret)
        return nil;

//    for (cur=head; cur!=NULL; cur=cur->ai_next) {
//        inet_ntop(AF_INET, &((struct sockaddr_in*)cur->ai_addr)->sin_addr, str, 16);
//    }

    pstr = inet_ntop(AF_INET, &((struct sockaddr_in*)head->ai_addr)->sin_addr, str, INET_ADDRSTRLEN);
    freeaddrinfo(head);
    
    if (pstr)
        return [NSString stringWithUTF8String:str];
    else
        return nil;
}

- (BOOL)getHostReachability:(NSString*)address target:(id)_target sel:(SEL)_sel
{
    for (id keys in pinger_once_dic) {
        if ([keys isEqualToString:address])
            return NO;
    }

    SimplePingDelegate *pinger_once = [SimplePingDelegate pingOnce:address target:self sel:@selector(pingOnceResult::)];
    NSValue *selectorAsValue = nil;
    if (_sel)
        selectorAsValue = [NSValue valueWithPointer:_sel];
    NSNumber *cnt = [NSNumber numberWithInt:0];
        
    NSMutableDictionary *node = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          pinger_once, @"pinger",
                          _target, @"target",
                          selectorAsValue, @"sel",
                          cnt, @"cnt",
                          nil];
    [pinger_once_dic setObject:node forKey:address];
    return YES;
}

@end

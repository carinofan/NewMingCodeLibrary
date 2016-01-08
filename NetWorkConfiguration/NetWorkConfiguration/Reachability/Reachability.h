/*
     File: Reachability.h
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

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

#import "Singleton.h"
#import "SimplePingDelegate.h"


extern NSString *kRouterReachabilityChangedNotification;
extern NSString *kHostReachabilityChangedNotification;

typedef enum : NSInteger {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN,
    ReachableViaVPN
} NetworkStatus;



@interface Reachability : NSObject
{
    BOOL _alwaysReturnLocalWiFiStatus; //default: NO
    SCNetworkReachabilityRef _reachabilityRef;
    
    char wifi_ip[INET_ADDRSTRLEN]; //wifi的ip
    char wwan_ip[INET_ADDRSTRLEN]; //3g的ip
    char ppp_ip[INET_ADDRSTRLEN]; //vpn的ip
    
    NSMutableDictionary *serverList;
    NSMutableDictionary *pinger_once_dic;
    
    NSString *path;
    NSMutableDictionary *root;
    
    int host_state;
}

singleton_interface(Reachability);

- (NetworkStatus)currentReachabilityStatus;
//+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
//+ (instancetype)reachabilityForInternetConnection;
//- (instancetype)reachabilityWithHostName:(NSString *)hostName;

/* Start listening for reachability notifications on the current run loop.
 * 开始对连通性进行监听，现在会同时刷新一次连通性状态，不需要手动调用currentReachabilityStatus方法
 */
- (BOOL) startNotifier;
/*
 * 停止监控
 */
- (void) stopNotifier;

/*
 * 增加服务器ip到serverList
 */
- (void) addRemoteHost:(NSString*)address;

/*
 * 从serverList删除项
 *
 * @param address   从serverList删除对应项；
 * @return          删除成功－YES，失败NO。
 */
- (BOOL) removeRemoteHostWithAddress:(NSString*)address;
- (int) getServerCnt;

/*
 * 开始使用路由优先级最高的本地端口ping服务器列表优先级最高的ip
 *
 * @param _target   暂时无用，可以填nil
 * @param _sel      同上
 *
 */
- (BOOL)startPing:(id)_target sel:(SEL)_sel;
/*
 * 停止ping
 */
- (void)stopPing;

///* 
// * 枚举当前网络接口，刷新这个类里面的wifi_ip、wwan_ip、ppp_ip三个变量。
// *
// * @return 现在可用网络界面的个数
// */
//- (int)refreshLocalIp;


- (void)sendBackgroundNotice:(BOOL)bg;

/*
 *  dns解析函数
 *
 *  @param host     需要解析的域名；
 *  @return         解析成功时为ip地址，不成功返回nil；
 */
- (NSString *)resolveHost:(NSString *)host;
/*
 *  检测目标服务器是否有响应(一次性检测／两次重试／总超时3s／可同时并发多个／每个目标只能同时进行一个)
 *
 *  @param address  服务器ip／域名；
 *  @param target   selector的所属的实例，即self
 *  @param sel      selector函数，第一个参数为[nsnumber numberwithbool:], 第二个参数为id；
 */
- (BOOL)getHostReachability:(NSString*)address target:(id)_target sel:(SEL)_sel;


@property (nonatomic,assign) NetworkStatus curNetStatus;
@property (nonatomic,assign) int failed_cnt;
@property (nonatomic,assign) int ping_retry;

@end



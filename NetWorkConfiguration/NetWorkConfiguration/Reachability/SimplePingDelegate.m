//
//  SimplePingHelper.m
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimplePingDelegate.h"
#include <netinet/in.h>
#include <arpa/inet.h>

NSString *kSimplePingEnterBackgroundNotification = @"kSimplePingEnterBackgroundNotification";

@interface SimplePingDelegate()

@property(nonatomic,retain) SimplePing* simplePing;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL sel;
@property(nonatomic,strong) NSTimer *ping_timer;
@property(nonatomic,strong) NSString *bind_addr;
@property(nonatomic,strong) NSString *target_addr;
@property(nonatomic,strong) NSString *target_host;
@property(nonatomic,assign) BOOL once;
@property(nonatomic,assign) int ping_processing;

- (id)initWithAddress:(NSString*)address if_addr:(NSString*)if_addr target:(id)_target sel:(SEL)_sel;
- (void)bgHandler:(NSNotification *)note;
- (void)go;
@end


@implementation SimplePingDelegate
@synthesize simplePing, target, sel;

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (instancetype)ping:(NSString*)targetAddress if_addr:(NSString*)if_addr target:(id)target sel:(SEL)sel
{
    SimplePingDelegate *ret = [[SimplePingDelegate alloc] initWithAddress:targetAddress if_addr:if_addr target:target sel:sel];
    ret.once = NO;
    
    [ret.simplePing start];
    return ret;
}

+ (instancetype)pingOnce:(NSString *)address target:(id)target sel:(SEL)sel
{
    SimplePingDelegate *ret = [[SimplePingDelegate alloc] initWithAddress:address if_addr:NULL target:target sel:sel];
    ret.once = YES;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bgHandler:) name:kSimplePingEnterBackgroundNotification object:nil];
    [ret.simplePing start];
    return ret;
}

#pragma mark - Init/dealloc

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_ping_timer invalidate];
	self.simplePing = nil;
	self.target = nil;
    self.bind_addr = nil;
}

- (void)dealloc {
    //NSLog(@"pinger %@ destoried", self);
    //[super dealloc];
}

- (id)initWithAddress:(NSString*)address if_addr:(NSString*)if_addr target:(id)_target sel:(SEL)_sel {
	if (self = [self init]) {
		self.simplePing = [SimplePing simplePingWithHostName:address];
		self.simplePing.delegate = self;
		self.target = _target;
		self.sel = _sel;
        self.target_host = address;
        self.bind_addr = if_addr;
	}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bgHandler:) name:kSimplePingEnterBackgroundNotification object:nil];
    //NSLog(@"pinger %@ created", self);

	return self;
}

- (void)bgHandler:(NSNotification *)note
{
    if (!_ping_timer)
        return;
    
    NSNumber *type = [note object];
    NSParameterAssert([type isKindOfClass:[NSNumber class]]);
    switch (type.intValue) {
        case 0:
            [_ping_timer setFireDate:[NSDate distantFuture]];
            break;
        case 1:
            [_ping_timer setFireDate:[NSDate date]];
        default:
            break;
    }
}

- (int)getPingSeq
{
    return [self.simplePing getPingSeq];
}

- (NSString*)getTargetAddr
{
    return self.target_addr;
}

- (NSString*)getTargetHost
{
    return self.target_host;
}

- (NSString*)getBindAddr
{
    return self.bind_addr;
}

#pragma mark - Go

- (void)go {
    if (!_ping_processing) {
        _ping_processing = 1;
        
        [self.simplePing sendPingWithData:nil];
        [self performSelector:@selector(timeOut) withObject:nil afterDelay:1];
    }
}

- (void)timeOut {
    if (_ping_processing) { // If it hasn't already been killed, then it's timed out
        [self end:NO];
        if (!_once)
            [_ping_timer setFireDate:[NSDate date]];
    }
}

- (void)end:(BOOL)isok
{
    _ping_processing = 0;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:self.sel withObject:[NSNumber numberWithBool:isok] withObject:self];
#pragma clang diagnostic pop
}

#pragma mark - Pinger delegate
// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
   
    const struct sockaddr_in *paddr = (const struct sockaddr_in *)[address bytes];
    _target_addr = [NSString stringWithUTF8String:inet_ntoa(paddr->sin_addr)];
    
    if (_bind_addr) {
        struct sockaddr_in bind_addr;
        bind_addr.sin_family = AF_INET;
        bind_addr.sin_addr.s_addr = inet_addr([_bind_addr UTF8String]);
        
        NSData *addr_data = [NSData dataWithBytes:&bind_addr length:sizeof(bind_addr)];
        [simplePing setBindIf:addr_data];
    }
    
    if (_once) {
        [self go];
    } else if (!_ping_timer) {
        _ping_timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(go) userInfo:nil repeats:YES];
        [_ping_timer setFireDate:[NSDate date]];
    }
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {

    [self end:NO];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
    
    [self end:NO];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {

    [self end:YES];
}

@end

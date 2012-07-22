//
//  MJNetworkClient.m
//  MegaJam
//
//  Created by Alex Belliotti on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJNetworkClient.h"

#import <netinet/in.h>

#define kServerSeekTimeoutInterval          30.0


@interface MJNetworkClient (Private)

- (void)discoveryTimerDidTimeout;

- (void)setupSocketWithNetService:(NSNetService *)service;

@end

@implementation MJNetworkClient

- (id)init {
    
    self = [super init];
    if (self) {
        
        _status = MJNetworkStatusDisconnected;
        
        self.bonjourBrowser = [[NSNetServiceBrowser alloc] init];
        _bonjourBrowser.delegate = self;
    }
    
    return self;
}

#pragma mark -
#pragma mark Service discovery
- (void)findMegaJams {
    
    //PRECONDITIONS
    if (self.status == MJNetworkStatusSeeking) return;
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.bonjourBrowser searchForServicesOfType:@"_MJServer._udp." inDomain:@""];
    //});
}


#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    
    int debug = 1 ;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    
    NSLog(@"Didn't get to seek, error!");
    
    self.status = MJNetworkStatusDisconnected;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    self.status = MJNetworStatusConnecting;
    
    if (self.socket) {
        self.socket = nil;
    }
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    aNetService.delegate = self;
    self.foundService = aNetService;
    [self.foundService resolveWithTimeout:10.0f];
   // });
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
    [self setupSocketWithNetService:sender];
    
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    
}

#pragma mark - 
#pragma mark UDP Socket

- (void)setupSocketWithNetService:(NSNetService *)service {
    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    
    NSData *anAddress = [service.addresses objectAtIndex:0];
    NSValue *valueForAddy = [NSValue valueWithBytes:&anAddress objCType:@encode(struct sockaddr)];
    
    struct sockaddr anAddrValue;
    [valueForAddy getValue:&anAddrValue];
    
    //  [socket bindToAddress:<#(NSString *)#> port:(UInt16)anAddrValue.ad error:<#(NSError *__autoreleasing *)#>]
    
    int debug = 1;
    //[socket bindToAddress port:service.port error:nil];
}


#pragma mark AsyncUdpSocketDelegate

@end

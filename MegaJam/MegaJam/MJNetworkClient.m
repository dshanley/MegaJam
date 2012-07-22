//
//  MJNetworkClient.m
//  MegaJam
//
//  Created by Alex Belliotti on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJNetworkClient.h"

#import <netinet/in.h>

#import "MJConstants.h"

#define kServerSeekTimeoutInterval          30.0


@interface MJNetworkClient (Private)

- (void)discoveryTimerDidTimeout;

- (void)setupSocketWithNetService:(NSNetService *)service;

- (NSString *)readableAddressWithData:(NSData *)data;

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

- (void)sendData:(float *)data {
    
    
    size_t dataSize = sizeof(data);
    size_t floatSize = sizeof(float);
    
    NSData *toSend = [NSData dataWithBytes:data length:(NSUInteger)dataSize];
//    float theData = *data;
//    NSTimeInterval unixTimeInterval = [[NSDate date] timeIntervalSince1970];
//    NSLog(@"DOWN THE WIRE: data=%f | tag=%f", theData, unixTimeInterval);
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.socket sendData:toSend toAddress:self.socketAddress withTimeout:1.0 tag:0/*unixTimeInterval*/];
    });
    
     
}

#pragma mark -
#pragma mark Service discovery
- (void)findMegaJams {
    
    //PRECONDITIONS
    if (self.status == MJNetworkStatusSeeking) return;
    
    
    [self.bonjourBrowser searchForServicesOfType:@"_MJServer._udp." inDomain:@""];
    
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
    [self.bonjourBrowser stop];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    
}

#pragma mark - 
#pragma mark UDP Socket

- (void)setupSocketWithNetService:(NSNetService *)service {
    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    self.socket = socket;
    
    if (!service.addresses.count >= 1) {
        [NSException raise:NSInternalInconsistencyException format:@"Has to be addys"];
    }
    /*
    for (NSData *data in service.addresses) {
        NSString *string = [self readableAddressWithData:data];
        int debug = 1;
    }
     */
    NSData *anAddress = [service.addresses objectAtIndex:0];
    
    self.socketAddress = anAddress;
    
    self.status = MJNetworkStatusConnected;
    
    NSNotification *socketConnectedNotif = [NSNotification notificationWithName:kNotificationSocketConnected
                                                                          object:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotification:socketConnectedNotif];
}


#pragma mark AsyncUdpSocketDelegate

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"Sending FAIL");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
    self.status = MJNetworkStatusDisconnected;
    NSLog(@"SOCKET CLOSED!!!");
}

#pragma mark -
#pragma mark Util

- (NSString *)readableAddressWithData:(NSData *)data {
    
    if (!data) return nil;
    
    NSValue *value = [NSValue valueWithBytes:&data objCType:@encode(struct sockaddr)];
    struct sockaddr addy;
    
    [value getValue:&addy];
    const char *constString = NULL;

    NSString *toReturn = [NSString stringWithUTF8String:addy.sa_data];
    return toReturn;
}

@end

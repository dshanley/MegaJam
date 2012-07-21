//
//  MJNetworkClient.m
//  MegaJam
//
//  Created by Alex Belliotti on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJNetworkClient.h"

#define kServerSeekTimeoutInterval          30.0

@interface MJNetworkClient (Private)

- (void)timerDidTimeout;

@end

@implementation MJNetworkClient

@synthesize wijourno = _wijourno;

@synthesize status = _status;


- (id)init {
    
    self = [super init];
    if (self) {
        Wijourno *wj  = [[Wijourno alloc] init];
        wj.delegate = self;
        _wijourno = wj;
        _status = MJNetworkStatusDisconnected;
    }
    
    return self;
}

- (void)findMegaJams {
    
    //PRECONDITIONS
    
    //start seeking
    [self.wijourno initClientWithServiceName:@"MJServer" dictionary:nil];
}

- (void) didReadCommand:(NSString *)command dictionary:(NSDictionary *)dictionary isServer:(BOOL)isServer {
    
}
- (void) connectionStarted:(NSString *)host {
    
}
- (void) connectionFinished:(NSString *)details {
    
}
- (void) readTimedOut {
    
}


@end

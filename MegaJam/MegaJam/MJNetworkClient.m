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

@synthesize browser = _browser;
@synthesize timeoutTimer = _timeoutTimer;

- (id)init {
    
    self = [super init];
    if (self) {
        _browser = [[HHServiceBrowser alloc] initWithType:@"MegaJamServer" domain:@"local."];
        _browser.delegate = self;
        
        _timeoutTimer = nil;
    }
    
    return self;
}

- (void)findMegaJams {
    
    //PRECONDITIONS
    if (self.isSeeking) return;
    
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
    
    self.seeking = YES;
    
    //start seeking
    [self.browser beginBrowse];
    
    //setup timer
    self.timeoutTimer = [NSTimer timerWithTimeInterval:kServerSeekTimeoutInterval target:self selector:@selector(timerDidTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
}

- (void)timerDidTimeout {
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    self.seeking = YES;
}

#pragma mark -
#pragma mark HHServiceDelegate

- (void)serviceBrowser:(HHServiceBrowser *)serviceBrowser didFindService:(HHService *)service moreComing:(BOOL)moreComing {
    
    int debug = 1;
}

- (void)serviceBrowser:(HHServiceBrowser *)serviceBrowser didRemoveService:(HHService *)service moreComing:(BOOL)moreComing {
    
}

@end

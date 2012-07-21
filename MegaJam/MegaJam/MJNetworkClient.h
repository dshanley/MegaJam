//
//  MJNetworkClient.h
//  MegaJam
//
//  Created by Alex Belliotti on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHServiceBrowser.h"

@interface MJNetworkClient : NSObject <HHServiceBrowserDelegate>

@property (nonatomic, strong) HHServiceBrowser *browser;
@property (nonatomic, strong) NSTimer *timeoutTimer;

@property (nonatomic, assign, getter = isSeeking) BOOL seeking;

- (void)findMegaJams;
- (void)sendData:(NSData *)data;

@end

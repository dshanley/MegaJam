//
//  MJNetworkClient.h
//  MegaJam
//
//  Created by Alex Belliotti on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Wijourno.h"

typedef enum {
    MJNetworkStatusDisconnected,
    MJNetworkStatusSeeking,
    MJNetworStatusConnecting,
    MJNetworkStatusConnected
} MJNetworkStatus;

@interface MJNetworkClient : NSObject <WijournoDelegate>

@property (nonatomic, strong) Wijourno *wijourno;

@property (nonatomic, assign) MJNetworkStatus status;

- (void)findMegaJams;
- (void)sendData:(NSData *)data;

@end

//
//  MJAudioIn.h
//  MegaJam
//
//  Created by Alex Belliotti on 7/21/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Novocaine.h"
#import "MJNetworkClient.h"

#import "MJPlayPauseDelegate.h"

@interface MJAudioIn : NSObject <MJPlayPauseDelegate>

@property (nonatomic, assign) BOOL audioInitd;
@property (nonatomic, strong) MJNetworkClient *networkClient;

- (void)startRecord;

@end

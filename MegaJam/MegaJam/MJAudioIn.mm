//
//  MJAudioIn.m
//  MegaJam
//
//  Created by Alex Belliotti on 7/21/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJAudioIn.h"

@implementation MJAudioIn

- (id)init {
    self = [super init];
    
    if (self) {
        _networkClient = [[MJNetworkClient alloc] init];
    }
    
    return self;
}

- (void)startRecord {
    
    Novocaine *audioManager = [Novocaine audioManager];
    
    audioManager.numInputChannels = 1;
    [audioManager checkSessionProperties];
    
    __block MJNetworkClient *clientPtr = self.networkClient;
    
    audioManager.inputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {
        [clientPtr sendData:data];
    };
}

- (void)playingAudio:(BOOL)isPlaying {
    
}

@end

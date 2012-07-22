//
//  MJPlayPauseDelegate.h
//  MegaJam
//
//  Created by Alex Belliotti on 7/21/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MJPlayPauseDelegate <NSObject>

- (void)playingAudio:(BOOL)isPlaying;

@end

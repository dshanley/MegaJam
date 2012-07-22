//
//  MJPlayPauseDelegate.h
//  MegaJam
//
//  Created by Alex Belliotti on 7/21/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MJPlayPauseDelegate <NSObject>

@optional

- (void)playPauseDelegateDidPlay:(id)delegate;
- (void)playPauseDelegateDidPause:(id)delegate;

@end

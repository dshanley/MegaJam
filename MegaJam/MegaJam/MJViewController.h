//
//  MJViewController.h
//  MegaJam
//
//  Created by Dave Shanley on 7/7/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioSession.h>
#import "MJThemedView.h"

@interface MJViewController : UIViewController <AVAudioSessionDelegate>
@property (nonatomic, unsafe_unretained) int viewTheme;

- (void)playAudio;

@end

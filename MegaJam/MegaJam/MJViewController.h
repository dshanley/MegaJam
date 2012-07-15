//
//  MJViewController.h
//  MegaJam
//
//  Created by Dave Shanley on 7/7/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioSession.h>

@interface MJViewController : UIViewController <AVAudioSessionDelegate>

- (void)playAudio;

@end

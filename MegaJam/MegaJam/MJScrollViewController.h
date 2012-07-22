//
//  MJScrollViewController.h
//  MegaJam
//
//  Created by Robert Corlett on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJThemedView.h"
#import "MJAudioIn.h"

@interface MJScrollViewController : UIViewController <UIScrollViewDelegate, MJPlayPauseDelegate>

@property (nonatomic, strong) MJAudioIn *audioIn;

@end

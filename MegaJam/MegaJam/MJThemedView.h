//
//  MJThemedView.h
//  MegaJam
//
//  Created by Robert Corlett on 7/15/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MJPlayPauseDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
	MJThemeRed = 1,
	MJThemeBlue = 2,
    MJThemeGreen = 3,
    MJThemeStone = 4,
    MJThemeCharcoal = 5
} MJTheme;


typedef enum {
    MJThemedViewStateNone,
    MJThemedViewStatePlaying,
    MJThemedViewStatePaused
} MJThemedViewState;

@interface MJThemedView : UIView {

}

@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *rotatorPlate;
@property (nonatomic, strong) UIView *backgroundPlate;
@property (nonatomic, assign) MJThemedViewState currentState;
@property (nonatomic, strong) NSMutableArray *delegates; /* MJPlayPauseDelegates quick hack should have accessors*/

+ (MJThemedView *)viewWithTheme:(MJTheme)theme andFrame:(CGRect)frame;


@end

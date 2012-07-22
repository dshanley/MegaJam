//
//  MJThemedView.h
//  MegaJam
//
//  Created by Robert Corlett on 7/15/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MJPlayPauseDelegate.h"

typedef enum {
	MJThemeRed, 
	MJThemeBlue,
    MJThemeGreen,
    MJThemeStone,
    MJThemeCharcoal
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

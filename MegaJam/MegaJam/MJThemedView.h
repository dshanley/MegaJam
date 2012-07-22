//
//  MJThemedView.h
//  MegaJam
//
//  Created by Robert Corlett on 7/15/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MJAudioIn.h"

typedef enum {
	MJThemeRed, 
	MJThemeBlue,
    MJThemeGreen,
    MJThemeStone,
    MJThemeCharcoal
} MJTheme;

@protocol playPauseDelegate <NSObject>

@required
- (void)playingAudio:(BOOL)isPlaying;

@end

@interface MJThemedView : UIView {
    id <playPauseDelegate> delegate;
}
@property (nonatomic, assign)id <playPauseDelegate> delegate;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *rotatorPlate;
@property (nonatomic, strong) UIView *backgroundPlate;

@property (nonatomic, strong) MJAudioIn *audioIn;

+ (MJThemedView *)viewWithTheme:(MJTheme)theme andFrame:(CGRect)frame;


@end

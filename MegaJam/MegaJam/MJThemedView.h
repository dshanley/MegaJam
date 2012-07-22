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

@interface MJThemedView : UIView {
    id <MJPlayPauseDelegate> delegate;
}
@property (nonatomic, assign)id <MJPlayPauseDelegate> delegate;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *rotatorPlate;
@property (nonatomic, strong) UIView *backgroundPlate;

+ (MJThemedView *)viewWithTheme:(MJTheme)theme andFrame:(CGRect)frame;


@end

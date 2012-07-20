//
//  MJThemedView.h
//  MegaJam
//
//  Created by Robert Corlett on 7/15/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJViewController.h"

typedef enum {
	MJThemeRed, 
	MJThemeBlue,
    MJThemeGreen,
    MJThemeStone,
    MJThemeCharcoal
} MJTheme;

@interface MJThemedView : UIView

@property (nonatomic, strong) MJViewController *controller;
@property (nonatomic, strong) UIImageView *grillActive;
@property (nonatomic, strong) UIImageView *grillFlat;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) NSString *viewTheme;

+ (MJThemedView *)viewWithTheme:(int)theme andFrame:(CGRect)frame;


@end

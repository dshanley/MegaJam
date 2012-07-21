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

+ (MJThemedView *)viewWithTheme:(MJTheme)theme andFrame:(CGRect)frame;


@end

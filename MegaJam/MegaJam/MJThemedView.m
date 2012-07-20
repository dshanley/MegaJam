//
//  MJThemedView.m
//  MegaJam
//
//  Created by Robert Corlett on 7/15/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

//Themes: red, blue, green, stone, charcoal
//Graphics: -bgk, -grill-flat, -grill-active, -play-up, -play-down, -pause-up, -pause-down

#import "MJThemedView.h"
#import "MJConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation MJThemedView

//static NSString *viewTheme;

@synthesize controller = _controller;
@synthesize grillActive = _grillActive;
@synthesize grillFlat = _grillFlat;
@synthesize pauseButton = _pauseButton;
@synthesize playButton = _playButton;
@synthesize viewTheme = _viewTheme;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.controller = [[MJViewController alloc] init];
        
        self.grillActive = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 130)];
        self.grillActive.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kGrillActiveBase]];
        
        self.grillFlat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 130)];
        self.grillFlat.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kGrillFlatBase]];
    }
    return self;
}

- (void) layoutSubviews {
    
    //Background
    UIImageView *backgoundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 330)];
    backgoundImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kBackgroundBase]];
    [self addSubview:backgoundImage];
    
    //Play Button
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(164, 144, 100, 100);
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPlayUpBase]] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPlayDownBase]] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPlayUpBase]] forState:UIControlStateNormal | UIControlStateHighlighted];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPlayDownBase]] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playButton];
    
    //Pause Button
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseButton.frame = CGRectMake(56, 144, 100, 100);
    [self.pauseButton setImage:[UIImage imageNamed:@"pause-up"] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:@"pause-down"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.pauseButton setImage:[UIImage imageNamed:@"pause-down"] forState:UIControlStateNormal | UIControlStateHighlighted];
    [self.pauseButton setImage:[UIImage imageNamed:@"pause-down"] forState:UIControlStateSelected];
    self.pauseButton.selected = YES;
    [self.pauseButton addTarget:self action:@selector(pausePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.pauseButton];
    
    //Volume Slider
    CGRect frame = CGRectMake(40, 270, 240, 10);
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:frame];
    [volumeSlider addTarget:self.controller action:@selector(adjustVolume:) forControlEvents:UIControlEventValueChanged];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    volumeSlider.minimumValue = 0.0;
    volumeSlider.maximumValue = 100.0;
    volumeSlider.value = 25.0;
    
    [self addSubview:volumeSlider];
    
    
    //bluetooth symbol
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    titleImage.image = [UIImage imageNamed:@"bluetooth-connected"];
    
    [self addSubview:titleImage];
    
    //Speaker Grill Images
    [self addSubview:self.grillActive];
    [self addSubview:self.grillFlat];
    
    
        
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)playPressed {
    //setting up animation
    NSLog(@"Play Pressed... ");
    
    self.pauseButton.selected = NO;
    self.playButton.selected = YES;
    
    CABasicAnimation *pulseAnimation;
    pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration = 0.35;
    pulseAnimation.repeatCount = 0;
    pulseAnimation.autoreverses = NO;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:0.0];
    pulseAnimation.fillMode = kCAFillModeForwards;
    pulseAnimation.removedOnCompletion = NO;
    [self.grillFlat.layer addAnimation:pulseAnimation forKey:@"animatePulse"];  
    
    
    [self.controller playAudio];
  
}

- (void)pausePressed {
    NSLog(@"Pause Pressed...");
    
    self.pauseButton.selected = YES;
    self.playButton.selected = NO;
    
    //setting up animation for grill
    CABasicAnimation *pulseAnimation;
    pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration = 0.35;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.0];
    [self.grillFlat.layer addAnimation:pulseAnimation forKey:@"animatePulse"]; 


}

+ (MJThemedView *)viewWithTheme:(int)theme andFrame:(CGRect)frame {
    
    MJThemedView *newView = [[MJThemedView alloc] initWithFrame:frame];
    
    switch (theme) {
        case MJThemeRed:
            newView.viewTheme = @"red";   
            break;
        case MJThemeBlue:
            newView.viewTheme = @"blue";
            break;
        case MJThemeGreen:
            newView.viewTheme = @"green";
            break;
        case MJThemeStone:
            newView.viewTheme = @"stone";
            break;
        case MJThemeCharcoal:
            newView.viewTheme = @"charcoal";
            break;
        default:
            newView.viewTheme = @"blue";
            break;
    }
    return newView;
}

//    CATransition *rippleAnimation = [CATransition animation];
//    [rippleAnimation setDelegate:self];
//    [rippleAnimation setDuration:2.0f];
//    [rippleAnimation setRepeatCount:MAXFLOAT];
//    [rippleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    [rippleAnimation setType:@"rippleEffect"];
//    [imageViewBackground.layer addAnimation:rippleAnimation forKey:@"rippleEffect"];



@end

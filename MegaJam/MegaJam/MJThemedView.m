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

#define kNumberOfGrills     3

@interface MJThemedView ()

@property (nonatomic, strong) UIImageView *grillActive;
@property (nonatomic, strong) UIImageView *grillFlat;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) NSString *viewTheme;
@property (nonatomic, strong) UIImageView *bluetoothImageOff;
@property (nonatomic, strong) UIImageView *bluetoothImageOn;
@property (nonatomic, strong) UIImageView *bluetoothImageWhite;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;

- (void)handleSingleTap;

@end

@implementation MJThemedView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.controller = [[MJViewController alloc] init];
    }
    return self;
}

- (void)setupThemedView {
    
    //add the gesture recognizer
    _grillFlat.userInteractionEnabled = YES;
    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [self.grillFlat addGestureRecognizer:_singleTapRecognizer];

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
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPauseUpBase]] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPauseDownBase]] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPauseDownBase]] forState:UIControlStateNormal | UIControlStateHighlighted];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kPauseDownBase]] forState:UIControlStateSelected];
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
    self.bluetoothImageOff = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    self.bluetoothImageOff.image = [UIImage imageNamed:@"gr-bluetooth-disconnected"];
    
    self.bluetoothImageOn = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    self.bluetoothImageOn.image = [UIImage imageNamed:@"gr-bluetooth-connected"];
    
    self.bluetoothImageWhite = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    self.bluetoothImageWhite.image = [UIImage imageNamed:@"gr-bluetooth-pulse"];

    [self addSubview:self.bluetoothImageWhite];
    [self addSubview:self.bluetoothImageOn];
    [self addSubview:self.bluetoothImageOff];
    
    //Hiding bluetooth
    [self makeViewInvisible:self.bluetoothImageOn];
    [self makeViewInvisible:self.bluetoothImageWhite];
    
    //MegaJam Title Image
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(112,72,100,26)];
    titleImage.image = [UIImage imageNamed:@"gr-megajam"];
    
    [self addSubview:titleImage];
    
    //Speaker Grill Images
    self.grillFlat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 130)];
    self.grillFlat.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewTheme, kGrillFlatBase]];
    
    self.grillActive = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 130)];
    
    [self addSubview:self.grillFlat];
    [self addSubview:self.grillActive];
    
    //Hide active grill
    [self makeViewInvisible:self.grillActive];
    
}

- (void) layoutSubviews {
    [super layoutSubviews];
    //custom layout?
        
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
    
    [self chooseRandomGrill];
    [self bluetoothOnEffect];
    
    [self.controller playAudio];
    [self.controller playAudioThroughSpeakerWithName:@"button-46.mp3"];

  
}

- (void)pausePressed {
    NSLog(@"Pause Pressed...");
    
    self.pauseButton.selected = YES;
    self.playButton.selected = NO;

    [self bluetoothOffEffect];
    [self.controller playAudioThroughSpeakerWithName:@"quick-blip.mp3"];
}

+ (MJThemedView *)viewWithTheme:(MJTheme)theme andFrame:(CGRect)frame {
    
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
    
    [newView setupThemedView];
    return newView;
}

- (void)bluetoothOnEffect {
    [self makeViewInvisible:self.bluetoothImageOff];
    [self makeViewVisible:self.bluetoothImageWhite];
    [self makeViewVisible:self.bluetoothImageOn];
    [self makeViewStrobe:self.bluetoothImageOn];
    
    CABasicAnimation *showGrill;
    showGrill = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showGrill.duration = 0.30;
    showGrill.repeatCount = 0;
    showGrill.autoreverses = NO;
    showGrill.fromValue = [NSNumber numberWithFloat:0.0];
    showGrill.toValue = [NSNumber numberWithFloat:1.0];
    showGrill.fillMode = kCAFillModeForwards;
    showGrill.removedOnCompletion = NO;
    [self.grillActive.layer addAnimation:showGrill forKey:@"animateImage"];
}

- (void)bluetoothOffEffect {
    [self makeViewInvisible:self.bluetoothImageOn];
    [self makeViewInvisible:self.bluetoothImageWhite];
    [self makeViewVisible:self.bluetoothImageOff];
    
    CABasicAnimation *hideGrill;
    hideGrill = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hideGrill.duration = 0.30;
    hideGrill.repeatCount = 0;
    hideGrill.autoreverses = NO;
    hideGrill.fromValue = [NSNumber numberWithFloat:1.0];
    hideGrill.toValue = [NSNumber numberWithFloat:0.0];
    hideGrill.fillMode = kCAFillModeForwards;
    hideGrill.removedOnCompletion = NO;
    [self.grillActive.layer addAnimation:hideGrill forKey:@"animateImage"];
    

}

- (void)makeViewInvisible:(UIImageView *)view {
    CABasicAnimation *hideAnimation;
    hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hideAnimation.duration = 0.0;
    hideAnimation.repeatCount = 0;
    hideAnimation.autoreverses = NO;
    hideAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    hideAnimation.toValue = [NSNumber numberWithFloat:0.0];
    hideAnimation.fillMode = kCAFillModeForwards;
    hideAnimation.removedOnCompletion = NO;
    [view.layer addAnimation:hideAnimation forKey:@"animateImage"];
    
}

- (void)makeViewVisible:(UIImageView *)view {
    CABasicAnimation *showAnimation;
    showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.duration = 0.0;
    showAnimation.repeatCount = 0;
    showAnimation.autoreverses = NO;
    showAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    showAnimation.toValue = [NSNumber numberWithFloat:1.0];
    showAnimation.fillMode = kCAFillModeForwards;
    showAnimation.removedOnCompletion = NO;
    [view.layer addAnimation:showAnimation forKey:@"animateImage"];
    
}

- (void)makeViewStrobe:(UIImageView *)view {
    CABasicAnimation *strobeAnimation;
    strobeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    strobeAnimation.duration = 1.0;
    strobeAnimation.repeatCount = MAXFLOAT;
    strobeAnimation.autoreverses = YES;
    strobeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    strobeAnimation.toValue = [NSNumber numberWithFloat:0.25];
    [view.layer addAnimation:strobeAnimation forKey:@"animateImage"];
}

- (void)chooseRandomGrill {
    NSString *grillName;
    int grillChoice = rand() % (kNumberOfGrills +1);
    switch (grillChoice) {
        case 1:
            grillName = @"gr-grill-hexagon";
            break;
        case 2:
            grillName = @"gr-grill-arrows";
            break;
        case 3:
            grillName = @"gr-grill-wavy";
            break;
        default:
            grillName = @"gr-grill-wavy";
            break;
    }
    self.grillActive.image = [UIImage imageNamed:grillName];
}

//    CATransition *rippleAnimation = [CATransition animation];
//    [rippleAnimation setDelegate:self];
//    [rippleAnimation setDuration:2.0f];
//    [rippleAnimation setRepeatCount:MAXFLOAT];
//    [rippleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    [rippleAnimation setType:@"rippleEffect"];
//    [imageViewBackground.layer addAnimation:rippleAnimation forKey:@"rippleEffect"];

////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations

- (void)handleSingleTap {
//    CATransition *animation = [CATransition animation];
//    [animation setDelegate:self];
//    [animation setDuration:2.0f];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [animation setType:@"rippleEffect" ];
//    [_grillFlat.layer addAnimation:animation forKey:NULL];
}



@end

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
#import <QuartzCore/QuartzCore.h>
#import "MJConstants.h"
#import "MJAppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

#define kNumberOfGrills     3

@interface MJThemedView ()
@property (nonatomic, strong) UIImageView *grillActive;
@property (nonatomic, strong) UIImageView *grillFlat;
@property (nonatomic, strong) NSString *viewThemeString;
@property (nonatomic, strong) UIImageView *bluetoothImageOff;
@property (nonatomic, strong) UIImageView *bluetoothImageOn;
@property (nonatomic, strong) UIImageView *bluetoothImageWhite;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapRecognizer;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UISlider *volumeSlider;

- (void)handleSingleTap;

@end

@implementation MJThemedView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnected) name:kNotificationSocketConnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketDisconnected) name:kNotificationSocketDisconnected object:nil];
        
        /* Not needed unless we want to use the volume for something later
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
         
         */

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerConnected) name:kNotificationSocketDisconnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDisconnected) name:kNotificationSocketDisconnected object:nil];
        
        //start off in paused
        self.currentState = MJThemedViewStatePaused;
        self.delegates = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupThemedView {
    
    //add the gesture recognizer
    _grillFlat.userInteractionEnabled = YES;
    self.singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [self.grillFlat addGestureRecognizer:_singleTapRecognizer];
    
    //Background Plate
    self.backgroundPlate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.backgroundPlate.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundPlate];

    //Tansparent Rotater Plate For Button Rotation
    self.rotatorPlate = [[UIView alloc]initWithFrame:CGRectMake(0,0,320,317)];
    self.rotatorPlate.backgroundColor = [UIColor clearColor];
    [self addSubview:self.rotatorPlate];
    
    //Background
    UIImageView *backgoundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 330)];
    backgoundImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kBackgroundBase]];
    [self.backgroundPlate addSubview:backgoundImage];
    
    //Play Button
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake(164, 134, 100, 100);
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPlayUpBase]] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPlayDownBase]] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPlayUpBase]] forState:UIControlStateNormal | UIControlStateHighlighted];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPlayDownBase]] forState:UIControlStateSelected];
    [self.playButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPlayDownBase]] forState:UIControlStateDisabled];
    [self.playButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setAdjustsImageWhenDisabled:NO];
    [self.playButton setAdjustsImageWhenHighlighted:NO];
    
    [self.rotatorPlate addSubview:self.playButton];
    
    //Pause Button
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseButton.frame = CGRectMake(56, 134, 100, 100);
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPauseUpBase]] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPauseDownBase]] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPauseDownBase]] forState:UIControlStateNormal | UIControlStateHighlighted];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPauseDownBase]] forState:UIControlStateSelected];
    [self.pauseButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kPauseDownBase]] forState:UIControlStateDisabled];
    self.pauseButton.selected = YES;
    [self.pauseButton addTarget:self action:@selector(pausePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton setAdjustsImageWhenDisabled:NO];
    [self.playButton setAdjustsImageWhenHighlighted:NO];
    
    [self.rotatorPlate addSubview:self.pauseButton];
    
    
    
    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(40, 270, 240, 10)];
    self.volumeView.showsRouteButton = NO;
    
    UISlider *volumeSlider;
    
    // Finding the MPVolumeView's UISlider in the view hierarchy and having our way with it...ohhhh baby!
    for (UIView *view in [self.volumeView subviews])
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) volumeSlider = (UISlider *)view;

    volumeSlider.minimumValue = 0.0;
    volumeSlider.maximumValue = 1.0;
    volumeSlider.value = 0.25;
    
    //Volume slider custom images
    UIImage *minImage = [UIImage imageNamed:@"gr-slider-fill"];
    UIImage *maxImage = [UIImage imageNamed:@"gr-slider-track"];
    UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",self.viewThemeString, kSliderBase]];
    minImage = [minImage stretchableImageWithLeftCapWidth:8.0 topCapHeight:0.0];
    maxImage = [maxImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    //Volume slider custom setup
    [volumeSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [volumeSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [volumeSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    [self.rotatorPlate addSubview:self.volumeView];
    
    //Volume icons
    UIImageView *volumeIconLow = [[UIImageView alloc] initWithFrame:CGRectMake(19, 269, 26, 26)];
    volumeIconLow.image = [UIImage imageNamed:@"gr-volume-low"];
    [self.rotatorPlate addSubview:volumeIconLow];
    
    UIImageView *volumeIconHigh = [[UIImageView alloc] initWithFrame:CGRectMake(282, 269, 26, 26)];
    volumeIconHigh.image = [UIImage imageNamed:@"gr-volume-high"];
    [self.rotatorPlate addSubview:volumeIconHigh];
    
    //bluetooth symbol
    self.bluetoothImageOff = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    self.bluetoothImageOff.image = [UIImage imageNamed:@"gr-bluetooth-disconnected"];
    
    self.bluetoothImageOn = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    self.bluetoothImageOn.image = [UIImage imageNamed:@"gr-bluetooth-connected"];
    
    self.bluetoothImageWhite = [[UIImageView alloc] initWithFrame:CGRectMake(147, 35, 25, 25)];
    self.bluetoothImageWhite.image = [UIImage imageNamed:@"gr-bluetooth-pulse"];
    
    //Hiding white bluetooth images
    [self makeViewInvisible:self.bluetoothImageWhite];
    [self makeViewInvisible:self.bluetoothImageOn];
    
    [self.rotatorPlate addSubview:self.bluetoothImageWhite];
    [self.rotatorPlate addSubview:self.bluetoothImageOn];

    [self.rotatorPlate addSubview:self.bluetoothImageOff];
    
    
    
    //MegaJam Title Image
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(112,72,100,26)];
    titleImage.image = [UIImage imageNamed:@"gr-megajam"];
    
    [self.rotatorPlate addSubview:titleImage];
    
    //Speaker Grill Images
    self.grillFlat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 150)];
    self.grillFlat.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", self.viewThemeString, kGrillFlatBase]];
    
    self.grillActive = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 150)];
    
    [self.backgroundPlate addSubview:self.grillFlat];
    [self.backgroundPlate addSubview:self.grillActive];
    
    //Hide active grill
    [self makeViewInvisible:self.grillActive];
}

/*
    We don't need this now since we're actually modifying the MPVolumeView directly
 
- (void) volumeChanged:(NSNotification *)notify
{
    UISlider *volumeViewSlider;
    
    // Find the MPVolumeSlider
    for (UIView *view in [self.volumeView subviews])
    {
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"])
        {
            volumeViewSlider = (UISlider *)view;
        }
    }
    
    NSLog(@"value: %f", volumeViewSlider.value);
    
    self.volumeSlider.value = volumeViewSlider.value;
}
*/

- (void)playPressed {
//    if (self.audioPlayer) NSLog(@"volume changed: %f", self.audioPlayer.volume);
    
    //setting up animation
    NSLog(@"Play Pressed... ");
    
    if (self.currentState == MJThemedViewStatePlaying) return;
    
    self.currentState = MJThemedViewStatePlaying;    
    
    for (id<MJPlayPauseDelegate>delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(playPauseDelegateDidPlay:)]) {
            [delegate playPauseDelegateDidPlay:self];
        }
    }
    
    self.pauseButton.selected = NO;
    self.playButton.selected = YES;
    
    [self chooseRandomGrill];
    [self bluetoothOnEffect];
    
    //DS shitty hack - fix the delegates
    MJAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.gkClient setMuted:NO];
    
   // [self.controller playAudio];
    //[self.controller playAudioThroughSpeakerWithName:@"button.mp3"];
}

- (void)pausePressed {
    NSLog(@"Pause Pressed...");
    
    if (self.currentState == MJThemedViewStatePaused) return;
    
    self.currentState = MJThemedViewStatePaused;
    
    for (id<MJPlayPauseDelegate>delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(playPauseDelegateDidPlay:)]) {
            [delegate playPauseDelegateDidPlay:self];
        }
    }
        
    self.pauseButton.selected = YES;
    self.playButton.selected = NO;

    MJAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.gkClient setMuted:YES];
    

    [self bluetoothOffEffect];
    //[self.controller playAudioThroughSpeakerWithName:@"button.mp3"];
}

+ (MJThemedView *)viewWithTheme:(MJTheme)theme andFrame:(CGRect)frame {
    
    MJThemedView *newView = [[MJThemedView alloc] initWithFrame:frame];
    
    switch (theme) {
        case MJThemeRed:
            newView.viewThemeString = @"red";
            break;
        case MJThemeBlue:
            newView.viewThemeString = @"blue";
            break;
        case MJThemeGreen:
            newView.viewThemeString = @"green";
            break;
        case MJThemeStone:
            newView.viewThemeString = @"stone";
            break;
        case MJThemeCharcoal:
            newView.viewThemeString = @"charcoal";
            break;
        default:
            newView.viewThemeString = @"blue";
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

- (void)socketConnected {
    NSLog(@"socket connected");
}

- (void)socketDisconnected {
    NSLog(@"socket disconnected");
}

- (void)peerConnected {
    [self performSelectorOnMainThread:@selector(bluetoothOnEffect) withObject:nil waitUntilDone:NO];
}

- (void)peerDisconnected {
    [self performSelectorOnMainThread:@selector(bluetoothOffEffect) withObject:nil waitUntilDone:NO];
}


@end

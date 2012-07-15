//
//  MJBlueBackgroundView.m
//  MegaJam
//
//  Created by Robert Corlett on 7/15/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJBlueBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MJBlueBackgroundView

@synthesize controller = _controller;
@synthesize grillActive = _grillActive;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.controller = [[MJViewController alloc] init];
        
        self.grillActive = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 130)];
        self.grillActive.image = [UIImage imageNamed:@"fpo-grill"];
    }
    return self;
}

- (void) layoutSubviews {
    
    //Background
    UIImageView *backgoundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 330)];
    backgoundImage.image = [UIImage imageNamed:@"bkg-blue"];
    [self addSubview:backgoundImage];
    
    //Play Button
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(164, 144, 100, 100);
    [playButton setImage:[UIImage imageNamed:@"play-up"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
    [playButton sizeToFit];
    
    [self addSubview:playButton];
    
    //Pause Button
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton.frame = CGRectMake(56, 144, 100, 100);
    [pauseButton setImage:[UIImage imageNamed:@"pause-down"] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pausePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:pauseButton];
    
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
    
    //Speaker Grill Image
    UIImageView *imageViewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 330, 320, 130)];
    imageViewBackground.image = [UIImage imageNamed:@"blue-grill-flat"];
    
    //    CATransition *rippleAnimation = [CATransition animation];
    //    [rippleAnimation setDelegate:self];
    //    [rippleAnimation setDuration:2.0f];
    //    [rippleAnimation setRepeatCount:MAXFLOAT];
    //    [rippleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    //    [rippleAnimation setType:@"rippleEffect"];
    //    [imageViewBackground.layer addAnimation:rippleAnimation forKey:@"rippleEffect"];
    
    [self addSubview:imageViewBackground];
        
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
    
    CABasicAnimation *pulseAnimation;
    pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration = 0.35;
    pulseAnimation.repeatCount = 0;
    pulseAnimation.autoreverses = NO;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.0];
    [self.grillActive.layer addAnimation:pulseAnimation forKey:@"animatePulse"];  
    [self addSubview:self.grillActive];
    self.grillActive.layer.zPosition = 1;
    
    [self.controller playAudio];
  
}

- (void)pausePressed {
    NSLog(@"Pause Pressed...");
    //setting up animation for grill
    CABasicAnimation *pulseAnimation;
    pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration = 0.35;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:0.0];
    pulseAnimation.fillMode = kCAFillModeForwards;
    pulseAnimation.removedOnCompletion = NO;
    [self.grillActive.layer addAnimation:pulseAnimation forKey:@"animatePulse"];    

}



@end

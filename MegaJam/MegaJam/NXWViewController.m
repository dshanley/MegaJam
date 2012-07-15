//
//  NXWViewController.m
//  MegaJam
//
//  Created by Dave Shanley on 7/7/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import "NXWViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>


@interface NXWViewController ()


@end


@implementation NXWViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg-blue"]];
    
    //Play Button
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(100, 140, 40, 20);
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    [playButton sizeToFit];
    
    [self.view addSubview:playButton];
    
    //Pause Button
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton.frame = CGRectMake(160, 140, 40, 20);
    [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseAudio) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton sizeToFit];
    
    [self.view addSubview:pauseButton];
    
    //Volume Slider
    CGRect frame = CGRectMake(40, 270, 240, 10);
    UISlider *volumeSlider = [[UISlider alloc] initWithFrame:frame];
    [volumeSlider addTarget:self action:@selector(adjustVolume:) forControlEvents:UIControlEventValueChanged];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
     volumeSlider.minimumValue = 0.0;
     volumeSlider.maximumValue = 100.0;
     volumeSlider.value = 25.0;
    
    [self.view addSubview:volumeSlider];
    
    
    //bluetooth symbol
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    titleImage.image = [UIImage imageNamed:@"bluetooth-connected"];
    [self.view addSubview:titleImage];
    
    //Speaker Grill Image
    UIImageView *imageViewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 320, 330, 285/2)];
    imageViewBackground.image = [UIImage imageNamed:@"fpo-grill"];
    
//    CATransition *rippleAnimation = [CATransition animation];
//    [rippleAnimation setDelegate:self];
//    [rippleAnimation setDuration:2.0f];
//    [rippleAnimation setRepeatCount:MAXFLOAT];
//    [rippleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    [rippleAnimation setType:@"rippleEffect"];
//    [imageViewBackground.layer addAnimation:rippleAnimation forKey:@"rippleEffect"];
    
    [self.view addSubview:imageViewBackground];
    
    
    
    // TODO: Make this a property so that we can conditinally add and remove this pulsating effect.
    //image 2
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 320, 330, 285/2)];
    imageView.image = [UIImage imageNamed:@"speaker2@2x.png"];
    
    //setting up animation
    CABasicAnimation *pulseAnimation;
    pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration = 1.0;
    pulseAnimation.repeatCount = MAXFLOAT;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:0.0];
    [imageView.layer addAnimation:pulseAnimation forKey:@"animatePulse"];
    
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)playAudio {
    NSLog(@"Playing Audio");
    // create and set up the audio session
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setDelegate:self];
    
    NSError *setupError = nil;
    [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord error:&setupError];
    BOOL isActive = [audioSession setActive: YES error: nil];
    
    // set up for bluetooth microphone input
    UInt32 allowBluetoothInput = 1;
    /*
    OSStatus stat = AudioSessionSetProperty (
                                             kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
                                             sizeof (allowBluetoothInput),
                                             &allowBluetoothInput
                                             );
     */
   // NSLog(@"status = %x", stat);    // problem if this is not zero
    
    // check the audio route
    UInt32 size = sizeof(CFStringRef);
    CFStringRef route;
    OSStatus result = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
    NSLog(@"route = %@", route);
    // if bluetooth headset connected, should be "HeadsetBT"
    // if not connected, will be "ReceiverAndMicrophone"
    
    // now, play a quick sound we put in the bundle (bomb.wav)
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef        soundFileURLRef;
    SystemSoundID   soundFileObject;
    //soundFileURLRef  = CFBundleCopyResourceURL (mainBundle,CFSTR ("you_talkin"),CFSTR ("wav"),NULL);
    NSString *const resourceDir = [[NSBundle mainBundle] resourcePath];
    NSString *const fullPath = [resourceDir stringByAppendingPathComponent:@"you_talkin.aiff"];
    NSURL *const url = [NSURL fileURLWithPath:fullPath];
    //BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:url.absoluteString];
    NSError *error = nil;
    BOOL exists = [url checkResourceIsReachableAndReturnError:&error];
    OSStatus err = AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url,&soundFileObject);
    NSError *playError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    AudioServicesPlaySystemSound (soundFileObject);     // should play into headset
    
    AudioServicesAddSystemSoundCompletion(soundFileObject, NULL, NULL, playSoundFinished, (__bridge_retained void *)self);
    
    // TODO: Start pulsating here
}

- (void)pauseAudio {
    //Pause Audio
    NSLog(@"Pause Pressed...");
}

- (void)adjustVolume: (id)sender {
    //Adjust Volume
    UISlider *slider = (UISlider *) sender;
    float value = slider.value;
    NSLog(@"Slider value = %f", value);
}
                                          
static void playSoundFinished (SystemSoundID soundID, void *data) {
    //Cleanup
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
    
    // TODO: Stop Pulsating
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AVAudioSessionDelegate



@end

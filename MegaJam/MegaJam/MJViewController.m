//
//  MJViewController.m
//  MegaJam
//
//  Created by Dave Shanley on 7/7/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import "MJViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#import "MJAudio.h"
#import "MJScrollViewController.h"

@interface MJViewController ()

@end


@implementation MJViewController
@synthesize viewTheme = _viewTheme;

- (void)loadView {
    [super loadView];
//    CGRect fullScreenRect = CGRectMake(0, 0, 320, 480);
//    MJScrollViewController *scrollView = [[MJScrollViewController alloc] init];
//    
//    [self.view addSubview:scrollView.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self playAudioThroughSpeakerWithName:@"CinematicBoom.mp3"];
    
    MJAudio *audioObject = [[MJAudio alloc] init];
    [audioObject configureAndInitializeAudioProcessingGraph];
    [audioObject startAUGraph];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || interfaceOrientation == UIInterfaceOrientationPortrait);
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
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;  
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,                         
                             sizeof (audioRouteOverride),                                      
                             &audioRouteOverride                                               
                             );
    
    
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
    NSString *const fullPath = [resourceDir stringByAppendingPathComponent:@"multimedia_button_click_029.mp3"];
    NSURL *const url = [NSURL fileURLWithPath:fullPath];
    //BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:url.absoluteString];
    NSError *error = nil;
    BOOL exists = [url checkResourceIsReachableAndReturnError:&error];
    OSStatus err = AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url,&soundFileObject);
    NSError *playError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    AudioServicesPlaySystemSound (soundFileObject);     // should play into headset
    
    AudioServicesAddSystemSoundCompletion(soundFileObject, NULL, NULL, playSoundFinished, (__bridge_retained void *)self);
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
}

- (void)playAudioThroughSpeakerWithName:(NSString *)fileName {
    NSLog(@"Playing Audio");
    // create and set up the audio session
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setDelegate:self];
    
    NSError *setupError = nil;
    [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord error:&setupError];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
    
    // now, play a quick sound we put in the bundle (bomb.wav)
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef        soundFileURLRef;
    SystemSoundID   soundFileObject;
    NSString *const resourceDir = [[NSBundle mainBundle] resourcePath];
    NSString *const fullPath = [resourceDir stringByAppendingPathComponent:fileName];
    NSURL *const url = [NSURL fileURLWithPath:fullPath];
    NSError *error = nil;
    BOOL exists = [url checkResourceIsReachableAndReturnError:&error];
    OSStatus err = AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url,&soundFileObject);
    NSError *playError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    AudioServicesPlaySystemSound (soundFileObject);     // should play into headset
    
    AudioServicesAddSystemSoundCompletion(soundFileObject, NULL, NULL, playSoundFinished, (__bridge_retained void *)self);
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AVAudioSessionDelegate



@end

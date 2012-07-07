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

@interface NXWViewController ()

@end

@implementation NXWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Play" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self.view addSubview:button];
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
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AVAudioSessionDelegate



@end

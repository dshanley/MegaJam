//
//  MJScrollViewController.m
//  MegaJam
//
//  Created by Robert Corlett on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJScrollViewController.h"
#import "MJConstants.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#import "MJAppDelegate.h"

static BOOL isOn = FALSE;

#define kNumberOfPages  5

@interface MJScrollViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *themedViews;

@property (strong, nonatomic) UIButton *rockerOff;
@property (strong, nonatomic) UIImageView *bluetoothImageOn;
@property (strong, nonatomic) UIImageView *bluetoothImageOff;
@property (strong, nonatomic) UIImageView *bluetoothImageWhite;

@end

@implementation MJScrollViewController

- (id)init {
    self = [super init];
    if (self) {
        self.themedViews = [[NSMutableArray alloc] initWithCapacity:kNumberOfPages];
        for (int i = 0; i < kNumberOfPages; ++i) {
            [self.themedViews addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    CGRect fullScreenRect = self.view.bounds;
    self.scrollView = [[UIScrollView alloc] initWithFrame:fullScreenRect];
    
    self.view = self.scrollView;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self.scrollView setContentOffset:CGPointMake(320.0, 0.0)];
    
    //load our switch view from nib
    UIView *switchView;
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MJSwitchView" owner:self options:nil];
    if (nibArray) {
        switchView = [nibArray objectAtIndex:0];
        self.rockerOff = (UIButton *)[switchView viewWithTag:50];
        [self.rockerOff addTarget:self action:@selector(toggleOnOff:) forControlEvents:UIControlEventTouchUpInside];
        self.bluetoothImageOff = (UIImageView *)[switchView viewWithTag:60];
        self.bluetoothImageOn = (UIImageView *)[switchView viewWithTag:61];
        self.bluetoothImageWhite = (UIImageView *)[switchView viewWithTag:62];
        
        [self makeViewInvisible:self.bluetoothImageOn];
        [self makeViewInvisible:self.bluetoothImageWhite];
        [self makeViewVisible:self.bluetoothImageOff];
    }
    [self.themedViews insertObject:switchView atIndex:0];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    MJThemedView *themedView = [self.themedViews objectAtIndex:page];
    if ((NSNull *)themedView == [NSNull null])
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        themedView = [MJThemedView viewWithTheme:page andFrame:frame];
//        themedView.delegate = self.audioIn;
        [self.themedViews insertObject:themedView atIndex:page];
        [self.scrollView addSubview:themedView];
        [self.themedViews replaceObjectAtIndex:page withObject:themedView];
    }
    
    if (themedView == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        themedView = [MJThemedView viewWithTheme:page andFrame:frame];
        //DS deprecated
//        [themedView.delegates addObject:self.audioIn];
        [self.themedViews insertObject:themedView atIndex:page];
        [self.scrollView addSubview:themedView];
    } else [self.scrollView addSubview:[self.themedViews objectAtIndex:0]];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{	
    int page = floor((self.scrollView.contentOffset.x - 320 / 2) / 320) + 1;

    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    //TODO: optimize orientation issues in some other way then constantly reloading everything.
    //Tripple checking things are in correct orientation
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        [self makeUpsideDown];
    }else [self makeRightSideUp];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
        if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            [self makeUpsideDown];
        }else {
            [self makeRightSideUp];
        }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
    self.scrollView.bounces = FALSE;
}

- (void) playingAudio:(BOOL)isPlaying {
    if (isPlaying) {
        self.scrollView.scrollEnabled = FALSE;
    } else {
        self.scrollView.scrollEnabled = TRUE;
    }
}

- (void)makeUpsideDown {
    float angle = M_PI;
    for (int i = 0; i < kNumberOfPages; ++i) {
        for (int i = 0; i < kNumberOfPages; ++i) {
            MJThemedView *currentView = [self.themedViews objectAtIndex:i];
            if ([currentView isKindOfClass:[MJThemedView class]]) {
                currentView.rotatorPlate.frame = CGRectMake(0, 138, 320, 317);
                currentView.backgroundPlate.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1.0);
            }
        }
    }
}

- (void)makeRightSideUp {
    for (int i = 0; i < kNumberOfPages; ++i) {
        for (int i = 0; i < kNumberOfPages; ++i) {
            MJThemedView *currentView = [self.themedViews objectAtIndex:i];
            if ([currentView isKindOfClass:[MJThemedView class]]) {
                currentView.rotatorPlate.frame = CGRectMake(0, 0, 320, 317);
                currentView.backgroundPlate.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1.0);
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MJPlayPauseDelegate

- (void)playPauseDelegateDidPlay:(id<MJPlayPauseDelegate>)delegate {
    MJAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.gkClient setMuted:NO];
}

- (void)playPauseDelegateDidPause:(id<MJPlayPauseDelegate>)delegate {
    MJAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.gkClient setMuted:YES];
}

////////////
//MJSwitchView
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

- (IBAction)toggleOnOff:(UIButton *)sender {
    if (isOn) {
        [self makeViewVisible:self.rockerOff.imageView];
        [self makeViewVisible:self.bluetoothImageOff];
        [self makeViewInvisible:self.bluetoothImageWhite];
        [self makeViewInvisible:self.bluetoothImageOn];
        isOn = FALSE;
    } else {
        //off
        [self makeViewInvisible:self.rockerOff.imageView];
        [self makeViewVisible:self.bluetoothImageWhite];
        [self makeViewStrobe:self.bluetoothImageOn];
        [self makeViewInvisible:self.bluetoothImageOff];
        isOn = TRUE;
        //look for net clients
        MJAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.gkClient performSelector:@selector(showPicker) withObject:nil afterDelay:1];
    }
    [self playAudioThroughSpeakerWithName:@"button.mp3"];
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

static void playSoundFinished (SystemSoundID soundID, void *data) {
    //Cleanup
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
}



@end






























//
//  MJAudio.h
//  MegaJam
//
//  Created by Tyler Powers on 7/19/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define NUM_FILES 2                         // number of audio files read in by old method

// Data structure for mono or stereo sound, to pass to the application's render callback function,
//    which gets invoked by a Mixer unit input bus when it needs more audio to play.
typedef struct {
    
    BOOL                 isStereo;           // set to true if there is data in the audioDataRight member
    UInt32               frameCount;         // the total number of frames in the audio data
    UInt32               sampleNumber;       // the next audio sample to play
    AudioUnitSampleType  *audioDataLeft;     // the complete left (or mono) channel of audio data read from an audio file
    AudioUnitSampleType  *audioDataRight;    // the complete right channel of audio data read from an audio file
    
} soundStruct, *soundStructPtr;

@interface MJAudio : NSObject <AVAudioSessionDelegate> {
    AUGraph processingGraph;
    soundStruct                     soundStructArray[NUM_FILES];    // scope reference for loop file callback
}

@property (nonatomic, assign) Float64                       graphSampleRate;
@property (nonatomic, assign) BOOL                          playing;
@property (nonatomic, assign) AudioStreamBasicDescription   stereoStreamFormat;
@property (nonatomic, assign) AUGraph                       processingGraph;
@property (nonatomic, assign) AudioUnit                     ioAudioUnit;
@property (nonatomic, assign) BOOL                          inputDeviceIsAvailable;

- (void) setupAudioSession;
- (void) setupStereoStreamFormat;
- (void) configureAndInitializeAudioProcessingGraph;
- (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;

@end

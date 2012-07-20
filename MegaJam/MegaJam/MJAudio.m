//
//  MJAudio.m
//  MegaJam
//
//  Created by Tyler Powers on 7/19/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJAudio.h"



// Audio session callback function for responding to audio route changes. If playing back audio and
//   the user unplugs a headset or headphones, or removes the device from a dock connector for hardware
//   that supports audio playback, this callback detects that and stops playback.
//
// Refer to AudioSessionPropertyListener in Audio Session Services Reference.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
    
    // Ensure that this callback was invoked because of an audio route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    // This callback, being outside the implementation block, needs a reference to the MixerHostAudio
    //   object, which it receives in the inUserData parameter. You provide this reference when
    //   registering this callback (see the call to AudioSessionAddPropertyListener).
    MJAudio *audioObject = (__bridge MJAudio *) inUserData;
    
    // if application sound is not playing, there's nothing to do, so return.
    if (NO == audioObject.playing) {
        
        NSLog (@"Audio route change while application audio is stopped.");
        return;
        
    } else {
        
        // Determine the specific type of audio route change that occurred.
        CFDictionaryRef routeChangeDictionary = inPropertyValue;
        
        CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
        SInt32 routeChangeReason;
        
        CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
        
        // "Old device unavailable" indicates that a headset or headphones were unplugged, or that
        //    the device was removed from a dock connector that supports audio output. In such a case,
        //    pause or stop audio (as advised by the iOS Human Interface Guidelines).
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
            NSLog (@"Audio output device was removed; stopping audio playback.");
            NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
            [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: audioObject];
            
        } else {
            
            NSLog (@"A route change occurred that does not require stopping application audio.");
        }
    }
}



static OSStatus inputRenderCallback (
                                     
                                     void                        *inRefCon,      // A pointer to a struct containing the complete audio data
                                     //    to play, as well as state information such as the
                                     //    first sample to play on this invocation of the callback.
                                     AudioUnitRenderActionFlags  *ioActionFlags, // Unused here. When generating audio, use ioActionFlags to indicate silence
                                     //    between sounds; for silence, also memset the ioData buffers to 0.
                                     const AudioTimeStamp        *inTimeStamp,   // Unused here.
                                     UInt32                      inBusNumber,    // The mixer unit input bus that is requesting some new
                                     //        frames of audio data to play.
                                     UInt32                      inNumberFrames, // The number of frames of audio to provide to the buffer(s)
                                     //        pointed to by the ioData parameter.
                                     AudioBufferList             *ioData         // On output, the audio data to play. The callback's primary
                                     //        responsibility is to fill the buffer(s) in the
                                     //        AudioBufferList.
                                     ) {
    NSLog(@"HERE!");
    
    soundStructPtr    soundStructPointerArray   = (soundStructPtr) inRefCon;
    UInt32            frameTotalForSound        = soundStructPointerArray[inBusNumber].frameCount;
    BOOL              isStereo                  = soundStructPointerArray[inBusNumber].isStereo;
    
    // Declare variables to point to the audio buffers. Their data type must match the buffer data type.
    AudioUnitSampleType *dataInLeft = NULL;
    AudioUnitSampleType *dataInRight;
    
    dataInLeft                 = soundStructPointerArray[inBusNumber].audioDataLeft;
    if (isStereo) dataInRight  = soundStructPointerArray[inBusNumber].audioDataRight;
    
    // Establish pointers to the memory into which the audio from the buffers should go. This reflects
    //    the fact that each Multichannel Mixer unit input bus has two channels, as specified by this app's
    //    graphStreamFormat variable.
    AudioUnitSampleType *outSamplesChannelLeft;
    AudioUnitSampleType *outSamplesChannelRight;
    
    
    
    outSamplesChannelLeft                 = (AudioUnitSampleType *) ioData->mBuffers[0].mData;
    if (isStereo) outSamplesChannelRight  = (AudioUnitSampleType *) ioData->mBuffers[1].mData;
    
    
    // Get the sample number, as an index into the sound stored in memory,
    //    to start reading data from.
    UInt32 sampleNumber = soundStructPointerArray[inBusNumber].sampleNumber;
    
    // Fill the buffer or buffers pointed at by *ioData with the requested number of samples
    //    of audio from the sound stored in memory.
    for (UInt32 frameNumber = 0; frameNumber < inNumberFrames; ++frameNumber) {
        
        outSamplesChannelLeft[frameNumber]                 = dataInLeft[sampleNumber];
        if (isStereo) outSamplesChannelRight[frameNumber]  = dataInRight[sampleNumber];
        
        sampleNumber++;
        
        // After reaching the end of the sound stored in memory--that is, after
        //    (frameTotalForSound / inNumberFrames) invocations of this callback--loop back to the
        //    start of the sound so playback resumes from there.
        if (sampleNumber >= frameTotalForSound) sampleNumber = 0;
    }
    
    // Update the stored sample number so, the next time this callback is invoked, playback resumes 
    //    at the correct spot.
    soundStructPointerArray[inBusNumber].sampleNumber = sampleNumber;
    
    return noErr;
}



@implementation MJAudio

@synthesize graphSampleRate = _graphSampleRate;
@synthesize playing = _playing;
@synthesize stereoStreamFormat = _stereoStreamFormat;
@synthesize processingGraph = processingGraph;
@synthesize ioAudioUnit = _ioAudioUnit;

- (id) init {
        
    self = [super init];
    
    if (!self) return nil;
    
    //self.interruptedDuringPlayback = NO;
    
    [self setupAudioSession];
    [self setupStereoStreamFormat];
    
    return self;
}


- (void) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: self];
    
    // Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback
                     error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting audio session category.");
        return;
    }
    
    
    
	self.inputDeviceIsAvailable = [mySession inputIsAvailable];
    //    NSAssert( micIsAvailable, @"No audio input device available." );
    
	
    if(self.inputDeviceIsAvailable) {
        NSLog(@"input device is available");
    }
    else {
        NSLog(@"input device not available...");
        [mySession setCategory: AVAudioSessionCategoryPlayback
                         error: &audioSessionError];
        
    }
    
    // Request the desired hardware sample rate.
    _graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: _graphSampleRate
                                        error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting preferred hardware sample rate.");
        return;
    }
    
    // Activate the audio session
    [mySession setActive: YES
                   error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error activating audio session during initial setup.");
        return;
    }
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession currentHardwareSampleRate];
    
    // Register the audio route change listener callback function with the audio session.
    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     (__bridge void *)(self)
                                     );
}


- (void) setupStereoStreamFormat {
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);

    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    _stereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    _stereoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    _stereoStreamFormat.mBytesPerPacket    = bytesPerSample;
    _stereoStreamFormat.mFramesPerPacket   = 1;
    _stereoStreamFormat.mBytesPerFrame     = bytesPerSample;
    _stereoStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    _stereoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    _stereoStreamFormat.mSampleRate        = _graphSampleRate;
    
    NSLog (@"Stereo stream format properties:");
    [self printASBD: _stereoStreamFormat];
}



#pragma mark -
#pragma mark Audio processing graph setup

// This method performs all the work needed to set up the audio processing graph:

// 1. Instantiate and open an audio processing graph
// 2. Obtain the audio unit nodes for the graph
// 3. Configure the Multichannel Mixer unit
//     * specify the number of input buses
//     * specify the output sample rate
//     * specify the maximum frames-per-slice
// 4. Initialize the audio processing graph

- (void) configureAndInitializeAudioProcessingGraph {
    
    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;
    
    //............................................................................
    // Create a new audio processing graph.
    result = NewAUGraph (&processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"NewAUGraph" withStatus: result]; return;}
    
    
    //............................................................................
    // Specify the audio unit component descriptions for the audio units to be
    //    added to the graph.
    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    //............................................................................
    // Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");
    
    AUNode   iONode;         // node for I/O unit
        
    // Add the nodes to the audio processing graph
    result =    AUGraphAddNode (
                                processingGraph,
                                &iOUnitDescription,
                                &iONode);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for I/O unit" withStatus: result]; return;}
    
    
    //............................................................................
    // Open the audio processing graph
    
    // Following this call, the audio units are instantiated but not initialized
    //    (no resource allocation occurs and the audio units are not in a state to
    //    process audio).
    result = AUGraphOpen (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphOpen" withStatus: result]; return;}
    
    
    //............................................................................
    // Obtain the io audio unit instance from its corresponding node.
    
    result =    AUGraphNodeInfo (
                                 processingGraph,
                                 iONode,
                                 NULL,
                                 &_ioAudioUnit
                                 );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNodeInfo" withStatus: result]; return;}
    
    
    //............................................................................
    // io unit Setup
    
    
    if(self.inputDeviceIsAvailable) {            // if no input device, skip this step
        AudioUnitElement ioUnitInputBus = 1;
        
        // Enable input for the I/O unit, which is disabled by default. (Output is
        //	enabled by default, so there's no need to explicitly enable it.)
        UInt32 enableInput = 1;
        
        AudioUnitSetProperty (
                              _ioAudioUnit,
                              kAudioOutputUnitProperty_EnableIO,
                              kAudioUnitScope_Input,
                              ioUnitInputBus,
                              &enableInput,
                              sizeof (enableInput)
                              );
        
        
        // Specify the stream format for output side of the I/O unit's
        //	input bus (bus 1). For a description of these fields, see
        //	AudioStreamBasicDescription in Core Audio Data Types Reference.
        //
        // Instead of explicitly setting the fields in the ASBD as is done
        //	here, you can use the SetAUCanonical method from the Core Audio
        //	"Examples" folder. Refer to:
        //		/Developer/Examples/CoreAudio/PublicUtility/CAStreamBasicDescription.h
        
        // The AudioUnitSampleType data type is the recommended type for sample data in audio
        //	units
        
        
        //  set the stream format for the callback that does processing
        // of the mic/line input samples
        
        // using 8.24 fixed point now because SInt doesn't work in stereo
        
        // Apply the stream format to the output scope of the I/O unit's input bus.        

        NSLog (@"Setting kAudioUnitProperty_StreamFormat (stereoStreamFormat) for the I/O unit input bus's output scope");
        result =	AudioUnitSetProperty (
                                          _ioAudioUnit,
                                          kAudioUnitProperty_StreamFormat,
                                          kAudioUnitScope_Output,
                                          ioUnitInputBus,
                                          &_stereoStreamFormat,
                                          sizeof (_stereoStreamFormat)
                                          );
        
        if (result) {[self printErrorMessage: @"AudioUnitSetProperty (set I/O unit input stream format output scope) stereoStreamFormat" withStatus: result]; return;}
    }    
	
    
    
    UInt32 inputBusCount   = 1;    // bus count for io audio unit input
    UInt32 inputBus        = 1;    // io audio unit bus 0 will be stereo
    /*
    NSLog (@"Setting io audio unit input bus count to: %lu", inputBusCount);
    result = AudioUnitSetProperty (
                                   _ioAudioUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &inputBusCount,
                                   sizeof (inputBusCount)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit bus count)" withStatus: result]; return;}
    
   */
    
    UInt32 outputBusCount   = 1;    // bus count for io audio unit input
    UInt32 outputBus   = 0;    // io audio unit bus 0 will be stereo
    
    /*
     
    NSLog (@"Setting io audio unit output bus count to: %lu", outputBusCount);
    result = AudioUnitSetProperty (
                                   _ioAudioUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Output,
                                   0,
                                   &outputBusCount,
                                   sizeof (outputBusCount)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit bus count)" withStatus: result]; return;}
    */

   /*
    
    NSLog (@"Setting kAudioUnitProperty_MaximumFramesPerSlice for mixer unit global scope");
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    
    result = AudioUnitSetProperty (
                                   mixerUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit input stream format)" withStatus: result]; return;}
    
    */
    
    
        
    // Setup the struture that contains the input render callback
    AURenderCallbackStruct inputCallbackStruct;
    inputCallbackStruct.inputProc        = &inputRenderCallback;
    inputCallbackStruct.inputProcRefCon  = soundStructArray;
    
    NSLog (@"Registering the render callback with io audio unit input bus %lu", inputBus);
    // Set a callback for the specified node's specified input
    result = AUGraphSetNodeInputCallback (
                                          processingGraph,
                                          iONode,
                                          inputBus,
                                          &inputCallbackStruct
                                          );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphSetNodeInputCallback" withStatus: result]; return;}

    
    
    
    
    
    
    NSLog (@"Setting stereo stream format for remot io input bus");
    result = AudioUnitSetProperty (
                                   _ioAudioUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Output,
                                   inputBus,
                                   &_stereoStreamFormat,
                                   sizeof (_stereoStreamFormat)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit guitar input bus stream format)" withStatus: result];return;}
    
    
    NSLog (@"Setting stereo stream format for remot io output bus");
    result = AudioUnitSetProperty (
                                   _ioAudioUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   outputBus,
                                   &_stereoStreamFormat,
                                   sizeof (_stereoStreamFormat)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit beats input bus stream format)" withStatus: result];return;}
    
    
    NSLog (@"Setting sample rate for mixer unit output scope");
    // Set the mixer unit's output sample rate format. This is the only aspect of the output stream
    //    format that must be explicitly set.
    result = AudioUnitSetProperty (
                                   _ioAudioUnit,
                                   kAudioUnitProperty_SampleRate,
                                   kAudioUnitScope_Input,
                                   0,
                                   &_graphSampleRate,
                                   sizeof (_graphSampleRate)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit output stream format)" withStatus: result]; return;}
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    NSLog (@"Connecting the mixer output to the input of the I/O unit output element");
    
    result = AUGraphConnectNodeInput (
                                      processingGraph,
                                      iONode,         // source node
                                      inputBus,                 // source node output bus number
                                      iONode,            // destination node
                                      outputBus                  // desintation node input bus number
                                      );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphConnectNodeInput" withStatus: result]; return;}
    
    
    //............................................................................
    // Initialize audio processing graph
    
    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing 
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);
    
    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    result = AUGraphInitialize (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphInitialize" withStatus: result]; return;}
}




#pragma mark -
#pragma mark Utility methods

// You can use this method during development and debugging to look at the
//    fields of an AudioStreamBasicDescription struct.
- (void) printASBD: (AudioStreamBasicDescription) asbd {
    
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}

- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {
    
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
    
    NSLog (
           @"*** %@ error: %s %08X %4.4s\n",
           errorString,
           (char*) &resultString
           );
}

- (void) startAUGraph  {
    
    NSLog (@"Starting audio processing graph");
    OSStatus result = AUGraphStart (processingGraph);
    if (noErr != result) {[self printErrorMessage: @"AUGraphStart" withStatus: result]; return;}
}

@end

//
//  MJGameKitClient.m
//  MegaJam
//
//  Created by Dave Shanley on 7/22/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJGameKitClient.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MJConstants.h"

#define kMegaJamClientName @"MegaJam"
#define kMegaJamServerName @"MegaJam Server"

/**
 Connect and manage VOIP over GameKit
 */
@interface MJGameKitClient ()

@property (nonatomic, strong) GKPeerPickerController *pickerController;
@property (nonatomic, strong) GKSession *chatSession;


- (void)closeConnectionWithMessage:(NSString *)message;

- (void)preparePeerPicker;
- (void)prepareAudioSystem;

@end


@implementation MJGameKitClient

- (void)startUp {
    //don't allow the device to go to sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self preparePeerPicker];
    [self prepareAudioSystem];
    [self setMuted:YES];
}

- (void)shutDown {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)preparePeerPicker {
    if (!!_pickerController) return;
    
    // Create a "peer picker"
    self.pickerController = [[GKPeerPickerController alloc] init];
    self.pickerController.delegate = self;
    // Search for peers only in the local bluetooth network
    self.pickerController.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
}

- (void)prepareAudioSystem {
    NSError *myErr;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //set to reducy audio lag and setup tonal properties
//    [audioSession setMode:AVAudioSessionModeVoiceChat error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
    [audioSession setActive:YES error:&myErr];
    
    // Routing default audio to external speaker
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                            sizeof(audioRouteOverride),
                            &audioRouteOverride);
    AudioSessionSetActive(true);
    
    [GKVoiceChatService defaultVoiceChatService].client = self;
}

- (void)showPicker {
    if (_pickerController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_pickerController show];
        });
    }
}

- (void)setMuted:(BOOL)isMuted {
    if (!_isMuted) {
        self.isMuted = YES;
        [[GKVoiceChatService defaultVoiceChatService] setMicrophoneMuted:YES];
    } else {
        self.isMuted = NO;
        [[GKVoiceChatService defaultVoiceChatService] setMicrophoneMuted:NO];
    }
}

- (void)closeConnectionWithMessage:(NSString *)message {
    NSLog(@"closeConnection %@", message);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeerDisConnected object:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.chatSession.delegate = nil;
    self.chatSession = nil;
}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark GKPeerPickerControllerDelegate


- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    NSString *sessionId = @"megajam";
    NSString *name = [NSString stringWithFormat:@"%@ (%@)", kMegaJamClientName, @""];
    GKSession* session = [[GKSession alloc] initWithSessionID:sessionId
                                                  displayName:[[UIDevice currentDevice] name]
                                                  sessionMode:GKSessionModePeer];
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    self.chatSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    picker.delegate = nil;
    
    [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:peerID
                                                                            error:nil];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    //let everyone know we are connected!
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeerConnected object:self];
    NSLog(@"peer connected: %@", peerID);
    [picker dismiss];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    [picker dismiss];
}

#pragma mark -
#pragma mark GKSessionDelegate methods

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (session == _chatSession)
    {
        switch (state)
        {
            case GKPeerStateAvailable:
                NSLog(@"GKPeerStateAvailable");
                break;
                
            case GKPeerStateUnavailable:
                NSLog(@"GKPeerStateUnAvailable");
                break;
                
            case GKPeerStateConnected:
                NSLog(@"GKPeerStateConnected");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeerConnected object:self];
                break;
                
            case GKPeerStateDisconnected:
                NSLog(@"GKPeerStateDisconnected");
                [self closeConnectionWithMessage:NSLocalizedString(@"peer disconnected", @"Shown when the other user disconnects")];
                break;
                
            case GKPeerStateConnecting:
                NSLog(@"GKPeerStateConnecting");
//                statusLabel.text = NSLocalizedString(@"connecting", @"Shown while the connection is negotiated");
                break;
                
            default:
                break;
        }
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    if (session == _chatSession) {
        [self closeConnectionWithMessage:NSLocalizedString(@"error", @"Shown when the connection generated an error")];
    }
}

#pragma mark -
#pragma mark GKVoiceChatClient methods

- (NSString *)participantID {
    return _chatSession.peerID;
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID {
    [_chatSession sendData:data
                  toPeers:[NSArray arrayWithObject:participantID]
             withDataMode:GKSendDataUnreliable error: nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data
                                             fromParticipantID:peer];
}


@end

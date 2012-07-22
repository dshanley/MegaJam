//
//  MJGameKitClient.h
//  MegaJam
//
//  Created by Dave Shanley on 7/22/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface MJGameKitClient : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate, GKVoiceChatClient>

- (void)startUp;
- (void)shutDown;
- (void)showPicker;

@end

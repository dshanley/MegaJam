//
//  MJAppDelegate.h
//  MegaJam
//
//  Created by Dave Shanley on 7/7/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJScrollViewController.h"
#import "MJGameKitClient.h"

#import "MJAudioIn.h"

@interface MJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MJScrollViewController *scrollViewController;
@property (nonatomic, strong) MJGameKitClient *gkClient;

@end

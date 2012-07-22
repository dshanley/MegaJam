//
//  MJScrollViewController.m
//  MegaJam
//
//  Created by Robert Corlett on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJScrollViewController.h"
#import "MJViewController.h"
#import "MJConstants.h"

#define kNumberOfPages  5

@interface MJScrollViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *themedViews;

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
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
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
        themedView.delegate = self;
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
        themedView.delegate = self;
        [self.themedViews insertObject:themedView atIndex:page];
        [self.scrollView addSubview:themedView];
    }
    
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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [UIView setAnimationsEnabled:NO];
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
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
                currentView.rotatorPlate.frame = CGRectMake(0, 133, 320, 317);
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

@end

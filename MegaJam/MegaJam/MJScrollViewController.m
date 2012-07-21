//
//  MJScrollViewController.m
//  MegaJam
//
//  Created by Robert Corlett on 7/20/12.
//  Copyright (c) 2012 CrowdComapss. All rights reserved.
//

#import "MJScrollViewController.h"
#import "MJViewController.h"

#define kNumberOfPages  5

@interface MJScrollViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *themedViews;
@end

@implementation MJScrollViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView {
    CGRect fullScreenRect = CGRectMake(0, 0, 320, 480);
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
        themedView = [MJThemedView viewWithTheme:page andFrame:CGRectMake(0, 0, 320, 480)];
        [self.themedViews replaceObjectAtIndex:page withObject:themedView];
    }
    
    // add the controller's view to the scroll view
    if (themedView == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        themedView = [MJThemedView viewWithTheme:page andFrame:frame];
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
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end

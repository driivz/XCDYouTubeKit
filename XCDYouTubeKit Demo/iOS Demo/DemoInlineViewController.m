//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import "DemoInlineViewController.h"

#import <XCDYouTubeKit/XCDYouTubeKit.h>

#import "MPMoviePlayerController+BackgroundPlayback.h"

@interface DemoInlineViewController ()

@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end

@implementation DemoInlineViewController

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// Beware, viewWillDisappear: is called when the player view enters full screen on iOS 6+
	if ([self isMovingFromParentViewController])
		[self.videoPlayerViewController.player pause];
}

- (IBAction) load:(id)sender
{
	[self.videoContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSString *videoIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"VideoIdentifier"];
	self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoIdentifier];
	
	self.videoPlayerViewController.view.frame = self.videoContainerView.bounds;
	self.videoPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self addChildViewController:self.videoPlayerViewController];
	[self.videoContainerView addSubview:self.videoPlayerViewController.view];
	[self.videoPlayerViewController didMoveToParentViewController:self];
}

- (IBAction) prepareToPlay:(UISwitch *)sender
{
	
}

@end

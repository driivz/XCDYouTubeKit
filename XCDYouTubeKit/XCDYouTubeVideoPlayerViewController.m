//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import "XCDYouTubeVideoPlayerViewController.h"

#import "XCDYouTubeClient.h"

NSString * const XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey = @"error"; // documented in -[MPMoviePlayerController initWithContentURL:]

NSString * const XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification = @"XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification";
NSString * const XCDYouTubeVideoPlayerViewControllerDidReceiveErrorNotification = @"XCDYouTubeVideoPlayerViewControllerDidReceiveErrorNotification";

NSString * const XCDYouTubeVideoUserInfoKey = @"Video";

@interface XCDYouTubeVideoPlayerViewController ()

@property (nonatomic, weak) id<XCDYouTubeOperation> videoOperation;

@property (nonatomic, copy, nullable, readwrite) NSString *videoIdentifier;

@end

@implementation XCDYouTubeVideoPlayerViewController

/*
 * MPMoviePlayerViewController on iOS 7 and earlier
 * - (id) init
 *        `-- [super init]
 *
 * - (id) initWithContentURL:(NSURL *)contentURL
 *        |-- [self init]
 *        `-- [self.moviePlayer setContentURL:contentURL]
 *
 * MPMoviePlayerViewController on iOS 8 and later
 * - (id) init
 *        `-- [self initWithContentURL:nil]
 *
 * - (id) initWithContentURL:(NSURL *)contentURL
 *        |-- [super init]
 *        `-- [self.moviePlayer setContentURL:contentURL]
 */

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		
	}
	
	return self;
}

- (instancetype)initWithVideoIdentifier:(NSString *)videoIdentifier
{
#if defined(DEBUG) && DEBUG
	NSString *callStackSymbols = [[NSThread callStackSymbols] componentsJoinedByString:@"\n"];
	if ([callStackSymbols rangeOfString:@"-[XCDYouTubeClient getVideoWithIdentifier:completionHandler:]_block_invoke"].length > 0)
	{
		NSString *reason = @"XCDYouTubeVideoPlayerViewController must not be used in the completion handler of `-[XCDYouTubeClient getVideoWithIdentifier:completionHandler:]`. Please read the documentation and sample code to properly use XCDYouTubeVideoPlayerViewController.";
		@throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
	}
#endif

	if ((self = [super init]))
	{
		// See https://github.com/0xced/XCDYouTubeKit/commit/cadec1c3857d6a302f71b9ce7d1ae48e389e6890
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
		
		if (videoIdentifier.length)
		{
			self.videoIdentifier = videoIdentifier;
		}
	}
	
	return self;
}

#pragma mark - Public

- (NSArray *) preferredVideoQualities
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		self->_preferredVideoQualities = @[ XCDYouTubeVideoQualityHTTPLiveStreaming, @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
	});
	
	return _preferredVideoQualities;
}

- (void) setVideoIdentifier:(NSString *)videoIdentifier
{
	if ([videoIdentifier isEqual:self.videoIdentifier])
		return;
	
	_videoIdentifier = [videoIdentifier copy];
	
	[self.videoOperation cancel];
	
	__weak typeof(self) weak = self;
	self.videoOperation = [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error)
						   {
							   if (video)
							   {
								   NSURL *streamURL = nil;
								   for (NSNumber *videoQuality in weak.preferredVideoQualities)
								   {
									   streamURL = video.streamURLs[videoQuality];
									   if (streamURL)
									   {
										   [weak startVideo:video streamURL:streamURL];
										   break;
									   }
								   }
								   
								   if (!streamURL)
								   {
									   NSError *noStreamError = [NSError errorWithDomain:XCDYouTubeVideoErrorDomain code:XCDYouTubeErrorNoStreamAvailable userInfo:nil];
									   [weak stopWithError:noStreamError];
								   }
							   }
							   else
							   {
								   [weak stopWithError:error];
							   }
						   }];
}

#pragma mark - Private

- (void) startVideo:(XCDYouTubeVideo *)video streamURL:(NSURL *)streamURL
{
	self.player = [AVPlayer playerWithURL:streamURL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification
														object:self
													  userInfo:@{ XCDYouTubeVideoUserInfoKey: video }];
}

- (void) stopWithError:(NSError *)error
{
	NSDictionary *userInfo = @{ XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey: error };
	[[NSNotificationCenter defaultCenter] postNotificationName:XCDYouTubeVideoPlayerViewControllerDidReceiveErrorNotification object:self.player userInfo:userInfo];
	
	[self.view removeFromSuperview];
}

#pragma mark - UIViewController

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (![self isBeingPresented]) {
		return;
	}
	
	[self.player play];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (![self isBeingDismissed])
	{
		return;
	}
	
	[self.videoOperation cancel];
}

@end

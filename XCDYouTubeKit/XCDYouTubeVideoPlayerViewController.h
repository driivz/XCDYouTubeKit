//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  -------------------
 *  @name Notifications
 *  -------------------
 */

/**
 *  NSError key for the `XCDYouTubeVideoPlayerViewControllerDidReceiveErrorNotification` userInfo dictionary.
 *
 *  Ideally, there should be a `XCDYouTubeVideoPlayerViewControllerDidReceiveErrorNotification` declared near to `MPMoviePlayerPlaybackDidFinishReasonUserInfoKey` in MPMoviePlayerController.h but since it doesn't exist, here is a convenient constant key.
 */
AVKIT_EXTERN NSString * const XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey;

AVKIT_EXTERN NSString * const XCDYouTubeVideoPlayerViewControllerDidReceiveErrorNotification;

/**
 *  Posted when the video player has received the video information. The `object` of the notification is the `XCDYouTubeVideoPlayerViewController` instance. The `userInfo` dictionary contains the `XCDYouTubeVideo` object.
 */
AVKIT_EXTERN NSString * const XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification;
/**
 *  The key for the `XCDYouTubeVideo` object in the user info dictionary of `XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification`.
 */
AVKIT_EXTERN NSString * const XCDYouTubeVideoUserInfoKey;

/**
 *  A subclass of `MPMoviePlayerViewController` for playing YouTube videos.
 *
 *  Use UIViewController’s `presentMoviePlayerViewControllerAnimated:` method to play a YouTube video fullscreen.
 *
 *  Use the `<presentInView:>` method to play a YouTube video inline.
 */

@interface XCDYouTubeVideoPlayerViewController : AVPlayerViewController

/**
 *  ------------------
 *  @name Initializing
 *  ------------------
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a YouTube video player view controller
 *
 *  @param videoIdentifier A 11 characters YouTube video identifier. If the video identifier is invalid the `MPMoviePlayerPlaybackDidFinishNotification` will be posted with a `MPMovieFinishReasonPlaybackError` reason.
 *
 *  @return An initialized YouTube video player view controller with the specified video identifier.
 *
 *  @discussion You can pass a nil *videoIdentifier* (or use the standard `init` method instead) and set the `<videoIdentifier>` property later.
 */
- (instancetype)initWithVideoIdentifier:(nullable NSString *)videoIdentifier;

/**
 *  ------------------------------------
 *  @name Accessing the video identifier
 *  ------------------------------------
 */

/**
 *  The 11 characters YouTube video identifier.
 */
@property (nonatomic, copy, nullable, readonly) NSString *videoIdentifier;

/**
 *  ------------------------------------------
 *  @name Defining the preferred video quality
 *  ------------------------------------------
 */

/**
 *  The preferred order for the quality of the video to play. Plays the first match when multiple video streams are available.
 *
 *  Defaults to @[ XCDYouTubeVideoQualityHTTPLiveStreaming, @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ]
 *
 *  You should set this property right after calling the `<initWithVideoIdentifier:>` method. Setting this property to nil restores its default values.
 *
 *  @see XCDYouTubeVideoQuality
 */
@property (nonatomic, copy, null_resettable) NSArray *preferredVideoQualities;

@end

NS_ASSUME_NONNULL_END

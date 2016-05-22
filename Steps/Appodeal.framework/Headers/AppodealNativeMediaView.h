//
//  AppodealNativeMediaView.h
//  Appodeal
//
//  Created by Stas Kochkin on 21/01/16.
//  Copyright © 2016 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Appodeal/AppodealNativeAd.h>


@protocol AppodealNativeMediaViewDelegate <NSObject>

@optional

- (void) mediaViewReady;
- (void) mediaViewError;
- (void) mediaViewStartPlaying;
- (void) mediaViewPresentFullScreen;
- (void) mediaViewCompleteVideoPlaying;
- (void) mediaViewSkip;

@end

@interface AppodealNativeMediaView : UIView

@property (nonatomic, strong) id <AppodealNativeMediaViewDelegate>  delegate;

//Default set to NO
@property (nonatomic, assign) BOOL fullscreenSupport;

- (instancetype) initWithNativeAd:(AppodealNativeAd *)nativeAd andRootViewController: (UIViewController*) controller;

- (void) prepareToPlay;
- (void) play;
- (void) pause;
- (void) setMute: (BOOL) mute;
- (void) stop;

@end

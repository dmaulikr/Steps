//
//  AppodealNativeAd.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 8/24/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppodealNativeAd.h"

@class AppodealNativeAdService;


@protocol AppodealNativeAdServiceRequestDelegate <NSObject>

- (void) nativeDidStart:(AppodealNativeAdService *) service;
- (void) requestDidStart:(AppodealNativeAdService *) service andNetwork: (NSString *) networkName;
- (void) requestDidFinish:(AppodealNativeAdService *) service andNetwork: (NSString *) networkName adFilled: (BOOL) filled;
- (void) nativeDidFinish:(AppodealNativeAdService *) service adFilled: (BOOL) filled;

@end

@protocol AppodealNativeAdServiceDelegate <NSObject>

@optional

- (void)nativeAdServiceDidLoad: (AppodealNativeAd*) nativeAd; // Use this method to get native ad instance
- (void)nativeAdServiceDidLoadSeveralAds __attribute__((deprecated));
- (void)nativeAdServiceDidFailedToLoad;

@end

@interface AppodealNativeAdService : NSObject

@property (weak, nonatomic) id<AppodealNativeAdServiceRequestDelegate> requestDelegate;
@property (weak, nonatomic) id<AppodealNativeAdServiceDelegate> delegate;
@property (assign, nonatomic, readonly, getter=isReady) BOOL ready;

- (void) loadAd;

- (AppodealNativeAd*) nextAd;

@end

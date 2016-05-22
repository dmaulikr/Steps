//
//  AppodealNativeAdsNewsFeedTemplate.h
//  Appodeal
//
//  Created by Учитель on 10.09.15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Appodeal/AppodealNativeAdViewAttributes.h>
#import <Appodeal/AppodealNativeAd.h>

typedef NS_ENUM(NSInteger, AppodealNativeAdViewType) {
    AppodealNativeAdTypeNewsFeed = 1, // Default size screen width * 75
    AppodealNativeAdTypeContentStream, // Default size screen width * 6*7*screen width
    AppodealNativeAdType320x50, 
    AppodealNativeAdType728x90
};

@interface AppodealNativeAdView : UIView

@property (nonatomic, assign, readonly) AppodealNativeAdViewType type;

@property (weak, nonatomic, nullable) UIViewController *rootViewController;

//Default set to NO

@property (nonatomic, assign) BOOL autoplayEnabled;

+(nonnull instancetype) nativeAdViewWithType:(AppodealNativeAdViewType)type andNativeAd:(nonnull AppodealNativeAd *)ad andAttributes:(nullable AppodealNativeAdViewAttributes *)attributes rootViewController: ( nonnull UIViewController*) controller;

@end


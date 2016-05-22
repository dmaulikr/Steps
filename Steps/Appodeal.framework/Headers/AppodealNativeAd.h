//
//  AppodealNativeAdModel.h
//  Appodeal
//
//  Created by Stanislav  on 06/11/15.
//  Copyright © 2015 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Appodeal/AppodealImage.h>
#import <Appodeal/AppodealConstants.h>

@class AppodealNativeAd;

@protocol AppodealNativeAdDelegate <NSObject>

@optional

- (void)nativeAdDidClick:(AppodealNativeAd *)nativeAd;
- (void)nativeAdDidPresent:(AppodealNativeAd *)nativeAd;

@end

@interface AppodealNativeAd : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *subtitle;
@property (copy, nonatomic, readonly) NSString *descriptionText;
@property (copy, nonatomic, readonly) NSString *callToActionText;
@property (copy, nonatomic, readonly) NSString *contentRating;
@property (copy, nonatomic, readonly) NSNumber *starRating;

@property (strong, nonatomic, readonly) AppodealImage *image;
@property (strong, nonatomic, readonly) AppodealImage *icon;

@property (weak, nonatomic) id<AppodealNativeAdDelegate> delegate;

- (void)attachToView:(UIView *)view viewController:(UIViewController *)viewController;
- (void)detachFromView;


- (void)sendClick __attribute__((deprecated));
- (void)sendImpression __attribute__((deprecated));

@end

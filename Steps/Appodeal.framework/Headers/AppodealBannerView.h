//
//  AppodealBannerView.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 11/9/15.
//  Copyright © 2015 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppodealBannerView;

@protocol AppodealBannerViewDelegate <NSObject>

@optional

- (void)bannerViewDidLoadAd:(AppodealBannerView *)bannerView;

- (void)bannerView:(AppodealBannerView *)bannerView didFailToLoadAdWithError:(NSError *)error;

- (void)bannerViewDidInteract:(AppodealBannerView *)bannerView;

@end

@protocol AppodealBannerViewRequestDelegate <NSObject>

- (void) bannerViewDidStart:(AppodealBannerView *) bannerView;
- (void) requestDidStart:(AppodealBannerView *) bannerView andNetwork: (NSString *) networkName;
- (void) requestDidFinish:(AppodealBannerView *) bannerView andNetwork: (NSString *) networkName adFilled: (BOOL) filled;
- (void) bannerViewDidFinish:(AppodealBannerView *) bannerView adFilled: (BOOL) filled;

@end


@interface AppodealBannerView : UIView

@property (weak, nonatomic) id<AppodealBannerViewDelegate> delegate;
@property (weak, nonatomic) id<AppodealBannerViewRequestDelegate> requestDelegate;
@property (assign, nonatomic, readonly, getter=isReady) BOOL ready;

- (instancetype)initWithSize:(CGSize)size rootViewController:(UIViewController *)rootViewController;

- (void)loadAd;

@end


@interface AppodealMRECView : AppodealBannerView

- (instancetype) initWithRootViewController: (UIViewController *) rootViewController;

@end
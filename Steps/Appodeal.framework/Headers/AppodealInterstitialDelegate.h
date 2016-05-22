//
//  AppodealInterstitialDelegate.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 25/07/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppodealInterstitialDelegate <NSObject>

@optional

- (void)interstitialDidLoadAd;
- (void)interstitialDidFailToLoadAd;
- (void)interstitialWillPresent;
- (void)interstitialDidDismiss;
- (void)interstitialDidClick;

@end
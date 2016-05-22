//
//  AppodealBannerDelegate.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 25/07/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppodealBannerDelegate <NSObject>

@optional

- (void)bannerDidLoadAd;

- (void)bannerDidFailToLoadAd;

- (void)bannerDidClick;

- (void)bannerDidShow;

@end

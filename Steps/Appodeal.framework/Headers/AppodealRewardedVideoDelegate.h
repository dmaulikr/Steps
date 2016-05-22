//
//  AppodealRewardedVideoDelegate.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 10/16/15.
//  Copyright © 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppodealRewardedVideoDelegate <NSObject>

@optional

- (void)rewardedVideoDidLoadAd;

- (void)rewardedVideoDidFailToLoadAd;

- (void)rewardedVideoDidPresent;

- (void)rewardedVideoWillDismiss;

- (void)rewardedVideoDidFinish:(NSUInteger)rewardAmount name:(NSString *)rewardName;

- (void) rewardedVideoDidClick;

@end

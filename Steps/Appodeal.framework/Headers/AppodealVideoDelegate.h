//
//  AppodealVideoDelegate.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 25/07/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppodealVideoDelegate <NSObject>

@optional

- (void)videoDidLoadAd;

- (void)videoDidFailToLoadAd;

- (void)videoDidPresent;

- (void)videoWillDismiss;

- (void)videoDidFinish;

- (void)videoDidClick;

@end


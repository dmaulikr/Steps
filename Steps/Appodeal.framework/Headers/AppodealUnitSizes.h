//
//  AppodealUnitSizes.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 07/07/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//


FOUNDATION_EXPORT const CGSize kAppodealUnitSize_320x50;
FOUNDATION_EXPORT const CGSize kAppodealUnitSize_300x250;
FOUNDATION_EXPORT const CGSize kAppodealUnitSize_728x90;

FOUNDATION_EXPORT NSArray * AppodealAvailableUnitSizes();

FOUNDATION_EXPORT BOOL AppodealIsUnitSizeSupported(const CGSize size, NSArray *supportedSizes);
FOUNDATION_EXPORT BOOL AppodealIsUnitSizeAvailable(const CGSize size);


FOUNDATION_EXPORT CGSize AppodealNearestUnitSizeForSize(CGSize size);
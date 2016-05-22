//
//  AppodealNativeAdViewAttributes.h
//  Appodeal
//
//  Created by Учитель on 14.09.15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppodealNativeAdViewAttributes : NSObject

@property (assign, nonatomic) BOOL roundedIcon;
@property (assign, nonatomic) BOOL sponsored;

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat heigth;

@property (copy, nonatomic) UIFont *titleFont;
@property (copy, nonatomic) UIFont *descriptionFont;
@property (copy, nonatomic) UIFont *subtitleFont;
@property (copy, nonatomic) UIFont *buttonTitleFont;

@property (copy, nonatomic) UIColor *titleFontColor;
@property (copy, nonatomic) UIColor *descriptionFontColor;
@property (copy, nonatomic) UIColor *subtitleColor;
@property (copy, nonatomic) UIColor *buttonColor;
@property (copy, nonatomic) UIColor *starRatingColor;

@end

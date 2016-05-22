//
//  AppodealAdChoicesView.h
//  Appodeal
//
//  Created by Stas Kochkin on 11/01/16.
//  Copyright © 2016 Appodeal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Appodeal/AppodealNativeAd.h>

@interface AppodealAdChoicesView : UIView

- (instancetype) initWithNativeAd: (AppodealNativeAd*) nativeAd;
- (void) setBackgroundColor:(UIColor *)backgroundColor;

@end

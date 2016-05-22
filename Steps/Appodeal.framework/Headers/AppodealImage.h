//
//  AppodealImage.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 9/14/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppodealImage : NSObject

@property (assign, nonatomic, readonly) CGSize size;
@property (copy, nonatomic, readonly) NSURL *imageUrl;


@end

//
//  AppodealConstants.h
//  Appodeal
//
//  Created by Ivan Doroshenko on 09/07/15.
//  Copyright (c) 2015 Appodeal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * AppodealSdkVersionString();
FOUNDATION_EXPORT NSString * AppodealApiVersionString();

typedef NS_ENUM(NSUInteger, AppodealUserGender) {
    AppodealUserGenderOther = 0,
    AppodealUserGenderMale,
    AppodealUserGenderFemale
};

typedef NS_ENUM(NSUInteger, AppodealUserOccupation) {
    AppodealUserOccupationOther = 0,
    AppodealUserOccupationWork,
    AppodealUserOccupationSchool,
    AppodealUserOccupationUniversity
};

typedef NS_ENUM(NSUInteger, AppodealUserRelationship) {
    AppodealUserRelationshipOther = 0,
    AppodealUserRelationshipSingle,
    AppodealUserRelationshipDating,
    AppodealUserRelationshipEngaged,
    AppodealUserRelationshipMarried,
    AppodealUserRelationshipSearching
};

typedef NS_ENUM(NSUInteger, AppodealUserSmokingAttitude) {
    AppodealUserSmokingAttitudeNegative = 1,
    AppodealUserSmokingAttitudeNeutral,
    AppodealUserSmokingAttitudePositive
};

typedef NS_ENUM(NSUInteger, AppodealUserAlcoholAttitude) {
    AppodealUserAlcoholAttitudeNegative = 1,
    AppodealUserAlcoholAttitudeNeutral,
    AppodealUserAlcoholAttitudePositive
};

#pragma mark - NativeVideo

typedef NS_ENUM(NSInteger, AppodealVideoEvent) {
    AppodealVideoEventStart = 0,
    AppodealVideoEventFinish,
    AppodealVideoEventSkip,
    AppodealVideoEventFirstQurtile,
    AppodealVideoEventMidpoint,
    AppodealVideoEventThirdQurtile,
    AppodealVideoEventClick,
    AppodealVideoEventReady,
    AppodealVideoEventError,
};

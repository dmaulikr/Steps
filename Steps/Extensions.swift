//
//  Extensions.swift
//  Steps
//
//  Created by Adam Binsz on 11/14/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation
import HealthKit
import Crashlytics

extension HKQuantityType {
    @nonobjc static let stepCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
    @nonobjc static let distanceWalkingRunning = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

class WeakContainer<T: AnyObject> {
    weak var value: T?
    init (value: T) {
        self.value = value
    }
}

extension Answers {
    static func logErrorWithName(name: String, error: NSError) {
        
        var attributes: [String : String] = ["domain" : error.domain, "code" : "\(error.code)", "description": error.description, "localizedDescription" : error.localizedDescription]
        
        if let localizedFailureReason = error.localizedFailureReason {
            attributes["localizedFailureReason"] = localizedFailureReason
        }
        
        if let localizedRecoverySuggestion = error.localizedRecoverySuggestion {
            attributes["localizedRecoverySuggestion"] = localizedRecoverySuggestion
        }
        
        logCustomEventWithName(name, customAttributes: attributes)
    }
}
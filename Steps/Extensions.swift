//
//  Extensions.swift
//  Steps
//
//  Created by Adam Binsz on 11/14/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation
import HealthKit

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


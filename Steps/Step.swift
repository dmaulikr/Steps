//
//  Step.swift
//  Steps
//
//  Created by Adam Binsz on 11/29/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import HealthKit

class Step {
    let date: Date
    var count: Int?
    var distance: HKQuantity?
    var distanceInPreferredUnit: Double? {
        get {
            let unit = Settings.useMetric ? HKUnit.meterUnit(with: HKMetricPrefix.kilo) : HKUnit.mile()
            return distance?.doubleValue(for: unit)
        }
    }
    
    init(date: Date) {
        self.date = date
    }
}

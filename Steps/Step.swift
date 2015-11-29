//
//  Step.swift
//  Steps
//
//  Created by Adam Binsz on 11/29/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import HealthKit

class Step {
    let date: NSDate
    var count: Int?
    var distance: HKQuantity?
    var distanceInPreferredUnit: Double? {
        get {
            let unit = Settings.useMetric ? HKUnit.meterUnitWithMetricPrefix(HKMetricPrefix.Kilo) : HKUnit.mileUnit()
            return distance?.doubleValueForUnit(unit)
        }
    }
    
    init(date: NSDate) {
        self.date = date
    }
}
//
//  StepCount.swift
//  Steps
//
//  Created by Adam Binsz on 9/27/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation
import HealthKit

class StepCount: CustomStringConvertible, CustomDebugStringConvertible {
    
    private static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    let startingDate: NSDate
    var dayName: String {
        return StepCount.dateFormatter.stringFromDate(startingDate)
    }
    
    var count: Int = 0
    var distance: HKQuantity
    
    init(startingDate: NSDate, stepCount count: Int = 0, distance: HKQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)) {
        self.startingDate = startingDate
        self.count = count
        self.distance = distance
    }
    
    var description: String {
        return "\(count) steps on " + dayName
    }
    
    var debugDescription: String {
        return "StepCount: \(count) steps on " + dayName + ", \(startingDate)"
    }
}
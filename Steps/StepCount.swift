//
//  StepCount.swift
//  Steps
//
//  Created by Adam Binsz on 9/27/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation

class StepCount: NSObject {
    let startingDate: NSDate
    let dayName: String
    var count: Int = 0
    
    init(startingDate: NSDate, dayName: String, stepCount count: Int = 0) {
        self.startingDate = startingDate
        self.dayName = dayName
        self.count = count
    }
    
    override var description: String {
        return "StepCount: \(count) on " + dayName + " \(startingDate)"
    }
}
//
//  StepInfo.swift
//  Steps
//
//  Created by Adam Binsz on 8/31/14.
//  Copyright (c) 2014 Adam Binsz. All rights reserved.
//

import UIKit

class StepInfo: NSObject {
   
    var date: NSDate
    var shortDateString: NSString
    var weekdayString: NSString
    var numberOfSteps: Int
    
    init(numberOfSteps count: Int, date stepDate: NSDate, shortDateString dateString: NSString, weekdayString weekday: NSString) {
        date = stepDate
        shortDateString = dateString
        numberOfSteps = count
        weekdayString = weekday
        super.init()
    }
    
    override var description: String {
        get {
            return "\(numberOfSteps) steps on " + weekdayString + ", " + shortDateString
        }
    }
}

//
//  Settings.swift
//  Steps
//
//  Created by Adam Binsz on 11/7/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation

let useMetricKey = "useMetric"

struct Settings {
    static var useMetric: Bool {
        if let useMetric = NSUserDefaults.standardUserDefaults().valueForKey(useMetricKey) as? Bool {
            return useMetric
        } else {
            let useMetric = (NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? Bool) ?? false
            NSUserDefaults.standardUserDefaults().setBool(useMetric, forKey: useMetricKey)
            return useMetric
        }
    }
}
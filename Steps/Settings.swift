//
//  Settings.swift
//  Steps
//
//  Created by Adam Binsz on 11/7/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation

struct Settings {
    
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    static func initializeDefaults() {
        if defaults.valueForKey(useMetricKey) == nil {
            let useMetric = (NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? Bool) ?? false
            defaults.setBool(useMetric, forKey: useMetricKey)
        }
    }
    
    static let useMetricKey = "useMetric"
    static var useMetric: Bool {
        get {
            return defaults.boolForKey(useMetricKey)
        }
        set {
            defaults.setBool(newValue, forKey: useMetricKey)
        }
    }
}
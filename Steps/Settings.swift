//
//  Settings.swift
//  Steps
//
//  Created by Adam Binsz on 11/7/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import Foundation

struct Settings {
    
    static let defaults = UserDefaults.standard
    
    static func initializeDefaults() {
        if defaults.value(forKey: useMetricKey) == nil {
            let useMetric = ((Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem) as? Bool) ?? false
            defaults.set(useMetric, forKey: useMetricKey)
        }
    }
    
    static let useMetricKey = "useMetric"
    static var useMetric: Bool {
        get {
            return defaults.bool(forKey: useMetricKey)
        }
        set {
            defaults.set(newValue, forKey: useMetricKey)
        }
    }
}

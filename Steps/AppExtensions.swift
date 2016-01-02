//
//  AppExtensions.swift
//  Steps
//
//  Created by Adam Binsz on 1/2/16.
//  Copyright © 2016 Adam Binsz. All rights reserved.
//

import Foundation
import Crashlytics

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
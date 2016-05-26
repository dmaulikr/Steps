//
//  Extensions.swift
//  Steps
//
//  Created by Adam Binsz on 11/14/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit
import HealthKit
import Crashlytics

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

extension Answers {
    static func logErrorWithName(name: String, error: NSError?) {
        
        var attributes: [String : String] = [:]
        
        if let error = error {
            attributes = ["domain" : error.domain, "code" : "\(error.code)", "description": error.description, "localizedDescription" : error.localizedDescription]
            
            if let localizedFailureReason = error.localizedFailureReason {
                attributes["localizedFailureReason"] = localizedFailureReason
            }
            
            if let localizedRecoverySuggestion = error.localizedRecoverySuggestion {
                attributes["localizedRecoverySuggestion"] = localizedRecoverySuggestion
            }
        }
        
        logCustomEventWithName(name, customAttributes: attributes)
    }
}

extension UIView {
    func constraintsEqualToSuperview(edgeInsets: UIEdgeInsets = UIEdgeInsetsZero) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if let superview = self.superview {
            constraints.append(self.constraintWithAttribute(.Leading, .Equal, to: superview, constant: edgeInsets.left))
            constraints.append(self.constraintWithAttribute(.Trailing, .Equal, to: superview, constant: edgeInsets.right))
            constraints.append(self.constraintWithAttribute(.Top, .Equal, to: superview, constant: edgeInsets.top))
            constraints.append(self.constraintWithAttribute(.Bottom, .Equal, to: superview, constant: edgeInsets.bottom))
        }
        return constraints
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to constant: CGFloat, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: multiplier, constant: constant)
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to otherAttribute: NSLayoutAttribute, of item: AnyObject? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item ?? self, attribute: otherAttribute, multiplier: multiplier, constant: constant)
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to item: AnyObject, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item, attribute: attribute, multiplier: multiplier, constant: constant)
    }
    
    func constraintsWithAttributes(attributes: [NSLayoutAttribute], _ relation: NSLayoutRelation, to item: AnyObject, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return attributes.map { self.constraintWithAttribute($0, relation, to: item, multiplier: multiplier, constant: constant) }
    }
}
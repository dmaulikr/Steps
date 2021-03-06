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
    @nonobjc static let stepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    @nonobjc static let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
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
    static func logErrorWithName(_ name: String, error: NSError?) {
        
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
        
        logCustomEvent(withName: name, customAttributes: attributes)
    }
}

extension UIView {
    class func springAnimateWithDuration(_ duration: TimeInterval, animations: @escaping () -> (), options: UIViewAnimationOptions = .allowUserInteraction, completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: options, animations: animations, completion: completion)
    }
    
    func constraintsEqualToSuperview(_ edgeInsets: UIEdgeInsets = UIEdgeInsets.zero, priority: UILayoutPriority = 1000) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if let superview = self.superview {
            constraints.append(self.constraintWithAttribute(.leading, .equal, to: superview, constant: edgeInsets.left, priority: priority))
            constraints.append(self.constraintWithAttribute(.trailing, .equal, to: superview, constant: -edgeInsets.right, priority: priority))
            constraints.append(self.constraintWithAttribute(.top, .equal, to: superview, constant: edgeInsets.top, priority: priority))
            constraints.append(self.constraintWithAttribute(.bottom, .equal, to: superview, constant: -edgeInsets.bottom, priority: priority))
        }
        return constraints
    }
    
    func constraintWithAttribute(_ attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to constant: CGFloat, multiplier: CGFloat = 1.0, priority: UILayoutPriority = 1000) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint =  NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        return constraint
    }
    
    func constraintWithAttribute(_ attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to otherAttribute: NSLayoutAttribute, of item: AnyObject? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0, priority: UILayoutPriority = 1000) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint =  NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item ?? self, attribute: otherAttribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        return constraint
    }
    
    func constraintWithAttribute(_ attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to item: AnyObject, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0, priority: UILayoutPriority = 1000) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item, attribute: attribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        return constraint
    }
    
    func constraintsWithAttributes(_ attributes: [NSLayoutAttribute], _ relation: NSLayoutRelation, to item: AnyObject, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0, priority: UILayoutPriority = 1000) -> [NSLayoutConstraint] {
        return attributes.map { self.constraintWithAttribute($0, relation, to: item, multiplier: multiplier, constant: constant, priority: priority) }
    }
}

extension UIColor {
    @nonobjc static let blueGradientTopColor = UIColor(red: 29.0/255.0, green: 97.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    @nonobjc static let blueGradientBottomColor = UIColor(red: 25.0/255.0, green: 213.0/255.0, blue: 253.0/255.0, alpha: 1.0)
}

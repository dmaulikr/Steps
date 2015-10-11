//
//  ViewController.swift
//  Steps
//
//  Created by Adam Binsz on 9/22/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit
import HealthKit
import OAStackView
import Async
import BRYXGradientView

class ViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    private let stackView = OAStackView()
    private var dayViews = [DayView]()
    
    private let healthStore = HKHealthStore()
    
    private var stepCounts = [StepCount]()
    private var maxStepCount: Int = 1
    var todayStepsTimer: NSTimer!
    
    private let numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topColor = UIColor(red: 29.0/255.0, green: 97.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 25.0/255.0, green: 213.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        let gradientView = GradientView(topColor: topColor, bottomColor: bottomColor)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientView, atIndex: 0)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[gradientView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["gradientView" : gradientView])
        )
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[gradientView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["gradientView" : gradientView])
        )
        
        
        let types: Set<HKObjectType> = [HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!]
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: types) { (authorized, error) -> Void in
            
        }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(scrollView, belowSubview: headerView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["scrollView" : scrollView])
        )
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[headerView][scrollView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["headerView": headerView, "scrollView": scrollView])
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView(==scrollView)]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["stackView" : stackView, "scrollView" : scrollView])
        )
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stackView(==scrollView@750)]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["stackView": stackView, "scrollView": scrollView])
        )
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[stackView(>=\(54 * 8))]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["stackView": stackView])
        )
        
        stackView.distribution = .FillEqually
        for _ in 0...7 {
            let dayView = DayView.loadFromNib()
            stackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        fetchStepCounts()
    }
    
    private func updateTodayStepCount() {
        guard let count = self.stepCounts.first?.count, dayView = dayViews.first else { return }
        
        let countString = numberFormatter.stringFromNumber(count)
        countLabel.text = countString
        
        dayView.countLabel.text = countString
        if count > maxStepCount {
            maxStepCount = count
            self.layoutChart()
        } else {
            updateBarAtIndex(0, animated: true)
        }
    }
    
    private func layoutChart(animated animated: Bool = false) {
        for index in 0..<stepCounts.count {
            updateBarAtIndex(index, animated: animated)
        }
    }
    
    private func updateBarAtIndex(index: Int, animated: Bool) {
        guard let stepCount = stepCounts[safe: index], dayView = dayViews[safe: index] else { return }
        
        dayView.dayLabel.text = stepCount.dayName
        dayView.countLabel.text = self.numberFormatter.stringFromNumber(stepCount.count)
        
        let duration = animated ? 0.88 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [.BeginFromCurrentState], animations: {
            dayView.barScale = max(CGFloat(stepCount.count) / CGFloat(self.maxStepCount), 0.025)
        }, completion: nil)
    }
    
    private func resetStepCounts() {
        stepCounts = [StepCount]()
        let calendar = NSCalendar.currentCalendar()
        var lastDate = NSDate()
        for _ in 0..<8 {
            if let date = calendar.nextDateAfterDate(lastDate, matchingHour: 0, minute: 0, second: 0, options: [.MatchStrictly, .SearchBackwards]) {
                lastDate = date
                let stepCount = StepCount(startingDate: date, dayName: dateFormatter.stringFromDate(date))
                stepCounts.append(stepCount)
            }
        }
        self.layoutChart(animated: false)
        self.updateTodayStepCount()
    }
    
    private func fetchStepCounts() {
        
        self.resetStepCounts()
        
        let calendar = NSCalendar.currentCalendar()
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            anchorDate = calendar.nextDateAfterDate(NSDate(), matchingHour: 0, minute: 0, second: 0, options: [.MatchStrictly, .SearchBackwards] as NSCalendarOptions) else { return }
        
        let intervalComponents = NSDateComponents()
        intervalComponents.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: intervalComponents)
        
        query.initialResultsHandler = { query, statisticsCollection, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let statisticsCollection = statisticsCollection else { return }
            
            for (index, stepCount) in self.stepCounts.enumerate() {
                if let statistics = statisticsCollection.statisticsForDate(stepCount.startingDate), sumQuantity = statistics.sumQuantity() {
                    let sum = Int(floor(sumQuantity.doubleValueForUnit(HKUnit.countUnit())))
                    stepCount.count = sum
                    
                    if sum > self.maxStepCount {
                        self.maxStepCount = sum
                    }
                }
                
                if index == self.stepCounts.count - 1 {
                    Async.main {
                        self.updateTodayStepCount()
                        self.layoutChart(animated: true)
                    }
                }
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            statisticsCollection?.enumerateStatisticsFromDate(calendar.nextDateAfterDate(NSDate(), matchingHour: 0, minute: 0, second: 0, options: [.MatchStrictly, .SearchBackwards])!, toDate: NSDate()) { statistics, stop in
                guard let sumQuantity = statistics.sumQuantity() else { return }
                Async.main {
                    self.stepCounts.first?.count = Int(floor(sumQuantity.doubleValueForUnit(HKUnit.countUnit())))
                    self.updateTodayStepCount()
                }
            }
        }
        
        healthStore.executeQuery(query)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

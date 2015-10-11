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
        
        let types: Set<HKObjectType> = [HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!]
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: types) { (authorized, error) -> Void in
            
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["stackView" : stackView])
        )
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[headerView][stackView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["headerView": headerView, "stackView": stackView])
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
        guard let count = self.stepCounts.first?.count else { return }
        
        let countString = numberFormatter.stringFromNumber(count)
        countLabel.text = countString
        
        stepCounts[0].count = count
        
        guard let dayView = dayViews.first else { return }
        
        dayView.countLabel.text = countString
        if count > maxStepCount {
            maxStepCount = count
            layoutChart()
        } else {
            dayView.barScale = CGFloat(count) / CGFloat(maxStepCount)
        }
    }
    
    private func layoutChart(animated animated: Bool = false) {
        for (index, stepCount) in stepCounts.enumerate() {
            let dayView = dayViews[index]
            dayView.dayLabel.text = stepCount.dayName
            dayView.countLabel.text = self.numberFormatter.stringFromNumber(stepCount.count)
            let barScale = CGFloat(stepCount.count) / CGFloat(self.maxStepCount)
            dayView.setBarScale(barScale, animated: true)
        }
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

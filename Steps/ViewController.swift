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
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        fetchStepCounts()
    }
    
    private func updateTodayStepCount(count: Int) {
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
    
    private func layoutChart() {
        for (index, stepCount) in stepCounts.enumerate() {
            let dayView = dayViews[index]
            dayView.dayLabel.text = stepCount.dayName
            dayView.countLabel.text = self.numberFormatter.stringFromNumber(stepCount.count)
            dayView.barScale = CGFloat(stepCount.count) / CGFloat(self.maxStepCount)
        }
    }
    
    private func fetchStepCounts() {
        let calendar = NSCalendar.currentCalendar()
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            anchorDate = calendar.nextDateAfterDate(NSDate(), matchingHour: 0, minute: 0, second: 0, options: [.MatchStrictly, .SearchBackwards] as NSCalendarOptions) else { return }
        
        let intervalComponents = NSDateComponents()
        intervalComponents.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: intervalComponents)
        query.initialResultsHandler = { query, statisticsCollection, error in
            if let error = error {
                print(error)
            }
            
            guard let statisticsCollection = statisticsCollection,
                startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: anchorDate, options: []),
                endDate = calendar.nextDateAfterDate(NSDate(), matchingHour: 23, minute: 59, second: 59, options: [.MatchStrictly]) else { return }
            
            var index = 7
            
            statisticsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { statistics, stop in
                guard let sumQuantity = statistics.sumQuantity() else { return }
                let sum = Int(round(sumQuantity.doubleValueForUnit(HKUnit.countUnit())))
                let dayName = self.dateFormatter.stringFromDate(statistics.startDate)
                
                let stepCount = StepCount(dayName: dayName, count: sum)
                self.stepCounts.insert(stepCount, atIndex: 0)
            
                if sum > self.maxStepCount { self.maxStepCount = sum }
                
                print(index)
                if index == 0 {
                    Async.main {
                        self.updateTodayStepCount(sum)
                        self.layoutChart()
                        return
                    }
                }
                
                index--
            }
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            statisticsCollection?.enumerateStatisticsFromDate(calendar.nextDateAfterDate(NSDate(), matchingHour: 0, minute: 0, second: 0, options: [.MatchStrictly, .SearchBackwards])!, toDate: NSDate()) { statistics, stop in
                guard let sumQuantity = statistics.sumQuantity() else { return }
                Async.main {
                    self.updateTodayStepCount(Int(round(sumQuantity.doubleValueForUnit(HKUnit.countUnit()))))
                }
            }
        }
        
        healthStore.executeQuery(query)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

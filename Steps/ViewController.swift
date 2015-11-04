//
//  ViewController.swift
//  Steps
//
//  Created by Adam Binsz on 9/22/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit
import iAd
import HealthKit
import OAStackView
import Async
import BRYXGradientView

class ViewController: UIViewController, ADBannerViewDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    private let scrollView = UIScrollView()
    private let stackView = OAStackView()
    private var dayViews = [DayView]()
    
    private let healthStore = HKHealthStore()
    
    private var stepCounts = [StepCount]()
    private var maxStepCount: Int = 1
    
    private let numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter
    }()
    
    private let bannerAdView = ADBannerView()
    private var bannerAdConstraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerAdView.delegate = self
        bannerAdView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerAdView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[adView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["adView" : bannerAdView])
        )
        setBannerAdHidden(true)
        
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
        
        scrollView.indicatorStyle = .White
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(scrollView, belowSubview: headerView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["scrollView" : scrollView])
        )
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[headerView][scrollView]-(0@750)-|",
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
        
        stackView.distribution = .FillEqually
        for _ in 0...7 {
            let dayView = DayView.loadFromNib()
            stackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
            
            dayView.addConstraint(NSLayoutConstraint(item: dayView,
                attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1.0,
                constant: 54)
            )
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        fetchHistoricalStepData()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "timeDidChangeSignificantly",
            name: AppDelegate.significantTimeChangeNotificationName,
            object: nil)
        
        
        let timer = NSTimer(timeInterval: 2.0, target: self, selector: "testBanner", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func timeDidChangeSignificantly() {
        fetchHistoricalStepData()
    }
    
    private func updateTodayStepCount() {
        guard let count = self.stepCounts.first?.count, dayView = dayViews.first else { return }
        
        let countString = numberFormatter.stringFromNumber(count)
        countLabel.text = countString
        
        dayView.countLabel.text = countString
        if count > maxStepCount {
            maxStepCount = count
            self.updateChart()
        } else {
            updateBarAtIndex(0, animated: true)
        }
    }
    
    private func updateChart(animated animated: Bool = false) {
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
            dayView.barScale = max(CGFloat(stepCount.count) / CGFloat(self.maxStepCount), 0.015)
        }, completion: nil)
    }
    
    private func resetStepCounts() {
        stepCounts = [StepCount]()
        let calendar = NSCalendar.currentCalendar()
        var lastDate = NSDate()
        for _ in 0..<8 {
            if let date = calendar.nextDateAfterDate(lastDate, matchingHour: 0, minute: 0, second: 0, options: [.MatchStrictly, .SearchBackwards]) {
                lastDate = date
                let stepCount = StepCount(startingDate: date)
                stepCounts.append(stepCount)
            }
        }
        self.updateChart()
        self.updateTodayStepCount()
    }
    
    private func fetchHistoricalStepData() {
        self.resetStepCounts()
        
        
        let stepCountResultsHandler: SumQuantitiesHandler = { dates, sums, error in
            
            if let error = error {
                print(error)
            }
            
            let integerSums = sums.map { Int(floor($0)) }
            self.maxStepCount = integerSums.maxElement() ?? 0
            print(self.maxStepCount)
            
            for (index, sum) in integerSums.enumerate() {
                self.stepCounts[safe: index]?.count = sum
            }
            
            Async.main {
                self.updateChart(animated: true)
            }
        }
        
        let dates = stepCounts.map { $0.startingDate }
        sumQuantitiesForDates(dates,
            quantityType: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
            unit: HKUnit.countUnit(),
            resultsHandler: stepCountResultsHandler,
            updateHandler: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    typealias SumQuantitiesHandler = ([NSDate], [Double], NSError?) -> ()
    func sumQuantitiesForDates(dates: [NSDate], quantityType: HKQuantityType, unit: HKUnit, resultsHandler: SumQuantitiesHandler?, updateHandler: SumQuantitiesHandler?) {
        
        let anchorDate = NSCalendar.currentCalendar().nextDateAfterDate(NSDate(),
            matchingHour: 0,
            minute: 0,
            second: 0,
            options: [.MatchStrictly] as NSCalendarOptions)!
        
        let intervalComponents = NSDateComponents()
        intervalComponents.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .CumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents)
        
        let sumStatistics: (HKStatisticsCollection?) -> [Double] = { statisticsCollection in
            
            var sums = [Double](count: dates.count, repeatedValue: 0.0)
            
            for (index, date) in dates.enumerate() {
                if let statistics = statisticsCollection?.statisticsForDate(date),
                    sumQuantity = statistics.sumQuantity() {
                        
                    let sum = sumQuantity.doubleValueForUnit(unit)
                    sums[index] = sum
                }
            }
        
            return sums
        }
        
        if let resultsHandler = resultsHandler {
            query.initialResultsHandler = { query, statisticsCollection, error in
                resultsHandler(dates, sumStatistics(statisticsCollection), error)
            }
        }
        
        if let updateHandler = updateHandler {
            query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
                updateHandler(dates, sumStatistics(statisticsCollection), error)
            }
        }
    
        healthStore.executeQuery(query)
    }
    
    // iAd delegate functions
    private var bannerHidden = false
    func setBannerAdHidden(hidden: Bool, animated: Bool = false) {
        
        if bannerHidden == hidden { return }
        
        view.removeConstraints(bannerAdConstraints)
        var constraints = [NSLayoutConstraint]()
        if hidden {
            constraints.append(NSLayoutConstraint(item: bannerAdView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: view,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0))
        } else {
            constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[scrollView][adView]|",
                options: .DirectionLeadingToTrailing,
                metrics: nil,
                views: ["scrollView" : scrollView,
                    "adView" : bannerAdView]
            )
        }
        bannerAdConstraints = constraints
        view.addConstraints(bannerAdConstraints)
        view.setNeedsLayout()
        
        let duration = animated ? 1.0 / 3.0 : 0.0
        UIView.animateWithDuration(duration, delay: 0.0, options: [], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        setBannerAdHidden(true, animated: true)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        setBannerAdHidden(false, animated: true)
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

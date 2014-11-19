//
//  MainViewController.swift
//  Steps
//
//  Created by Adam Binsz on 8/27/14.
//  Copyright (c) 2014 Adam Binsz. All rights reserved.
//

import UIKit
import QuartzCore
import CoreMotion

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let blueBackgroundColor = UIColor(red: 27.0/255.0, green: 155.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    let cellIdentifier = "StepCell"
    let animationConstant = 10.0 / 9.0
    var finishedLoadingHistoricalStepData = false
    
    var headerView: UIView!
    var headerToolbar: UIToolbar!
    var gradient: CAGradientLayer!
    var countLabel: UICountingLabel!
    var tableView: UITableView!
    
    let dateFormatter = NSDateFormatter()
    var numberFormatter: NSNumberFormatter {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            return appDelegate.numberFormatter
        }
    }
    var daysInTable: UInt = 8
    var stepCounts: [StepInfo]!
    let stepCounter = CMStepCounter()
    var maxNumberOfSteps = 0
    var numberOfStepsEarlierToday: Int = 0
    var numberOfStepsToday: Int = 0
    var numberOfCellsAnimated: CGFloat = 0
    var maxNumberOfCellsVisible: CGFloat {
        get {
            var visible = ceil((CGRectGetHeight(tableView.frame) - CGRectGetHeight(headerView.frame)) / tableView.estimatedRowHeight)
            if visible > CGFloat(daysInTable) {
                visible = CGFloat(daysInTable)
            }
            return visible
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = blueBackgroundColor
        
        if !CMStepCounter.isStepCountingAvailable() {
            let sorryLabel = UILabel()
            sorryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            sorryLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 26.0)
            sorryLabel.text = "Steps works only with the iPhone 5s, iPhone 6, and iPhone 6 Plus."
            sorryLabel.numberOfLines = 0
            sorryLabel.textAlignment = NSTextAlignment.Center
            sorryLabel.textColor = UIColor.whiteColor()
            view.addSubview(sorryLabel)
            
            view.addConstraint(NSLayoutConstraint(item: sorryLabel, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: sorryLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=8)-[sorryLabel]-(>=8)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sorryLabel" : sorryLabel]))
            
            return;
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil);
        
        automaticallyAdjustsScrollViewInsets = false
        
        countLabel = UICountingLabel()
        countLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        countLabel.formatBlock = {(floatVal: Float) -> String in
            return Int(floatVal).formattedString()
        }
        
        var countLabelFontSize:CGFloat = 80.0
        if UIScreen.mainScreen().scale > 2.0 {
            countLabelFontSize *= 1.2
        }
        countLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: countLabelFontSize)
        countLabel.textColor = UIColor.whiteColor()
//        countLabel.text = "9,863"
        countLabel.textAlignment = .Center
        countLabel.text = "0"
        view.addSubview(countLabel)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=8)-[countLabel]-(>=8)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["countLabel" : countLabel]))
        view.addConstraint(NSLayoutConstraint(item: countLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        var countLabelTopPadding: CGFloat = 15
        if UIScreen.mainScreen().scale > 2.0 {
            countLabelTopPadding = 14 + (2.0/3.0)
        }
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[top]-(\(countLabelTopPadding))-[countLabel]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["top" : topLayoutGuide, "countLabel" : countLabel]))
        
        let todayLabel = UILabel()
        todayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        var todayLabelFontSize:CGFloat = 28.0
        if UIScreen.mainScreen().scale > 2.0 {
            todayLabelFontSize *= 1.2
        }
        todayLabel.font = UIFont(name: "HelveticaNeue-Light", size: 24.0)
        todayLabel.textColor = UIColor.whiteColor()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.doesRelativeDateFormatting = true
        todayLabel.text = "Steps " + dateFormatter.stringFromDate(NSDate())
        view.addSubview(todayLabel)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=8)-[todayLabel]-(>=8)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["todayLabel" : todayLabel]))
        view.addConstraint(NSLayoutConstraint(item: todayLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[countLabel]-(-2)-[todayLabel]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["countLabel" : countLabel, "todayLabel" : todayLabel]))
        
        headerView = UIView()
        headerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.insertSubview(headerView, belowSubview: countLabel)
        view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0))
        var todayLabelBottomPadding: CGFloat = 29.5
        if UIScreen.mainScreen().scale > 2.0 {
            todayLabelBottomPadding = 37
        }
        view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .Bottom, relatedBy: .Equal, toItem: todayLabel, attribute: .Bottom, multiplier: 1.0, constant: todayLabelBottomPadding))
        view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        
        gradient = CAGradientLayer()
        gradient.colors = [blueBackgroundColor.CGColor!, blueBackgroundColor.CGColor!, blueBackgroundColor.colorWithAlphaComponent(0.0).CGColor!]
        gradient.locations = [0.0, 0.88, 1.0]
        headerView.layer.addSublayer(gradient)
        
        tableView = UITableView()
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.delegate = self
        tableView.alwaysBounceVertical = true
        tableView.bounces = true
        tableView.dataSource = self
        tableView.backgroundColor = blueBackgroundColor
        tableView.registerClass(StepCell.self, forCellReuseIdentifier: cellIdentifier)
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60
        } else {
            tableView.rowHeight = 58
        }
        tableView.separatorStyle = .None
        view.insertSubview(tableView, belowSubview: headerView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[tableView]-(0)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["tableView" : tableView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[tableView]-(0)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["tableView" : tableView]))
        
        countLabel.isAccessibilityElement = false
        todayLabel.isAccessibilityElement = false
        
        loadHistoricalStepData()
    }
    
    deinit {
         NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func loadHistoricalStepData() {
        
        if !CMStepCounter.isStepCountingAvailable() {
            return
        }
        
        maxNumberOfSteps = 0
        finishedLoadingHistoricalStepData = false
        stepCounts = [StepInfo]()
        
//        let fakeStepCounts: [Int] = [8834, 7040, 9568, 10892, 10361, 9183, 8540, 10484]
        
        for index: Int in 0...daysInTable - 1 {
            let beginningOfDay = NSDate.dateDaysFromNow(-1 * index).beginningOfDay()
            let endOfDay = beginningOfDay.endOfDay()
        
            dateFormatter.dateFormat = "MMMM"
            let month = dateFormatter.stringFromDate(beginningOfDay)
            dateFormatter.dateFormat = "d"
            let dayNumber = dateFormatter.stringFromDate(beginningOfDay)
            dateFormatter.dateFormat = "eeee"
            let dayName = dateFormatter.stringFromDate(beginningOfDay)
            
            stepCounter.queryStepCountStartingFrom(beginningOfDay, to: endOfDay, toQueue: NSOperationQueue.mainQueue(), withHandler: { (numberOfSteps, error) -> Void in
                
                if (error != nil) {
                    Flurry.logError(error.localizedDescription, message: "", error: error)
                }
                

                var stepInfo = StepInfo(numberOfSteps: numberOfSteps, date: beginningOfDay, shortDateString: month + " " + dayNumber, weekdayString: dayName)
                
                if numberOfSteps > self.maxNumberOfSteps {
                    self.maxNumberOfSteps = numberOfSteps
                }
                
                self.stepCounts.append(stepInfo)
                
                if index == 0 {
                    self.numberOfStepsEarlierToday = stepInfo.numberOfSteps
                    self.numberOfStepsToday = stepInfo.numberOfSteps
                    self.startPedometerUpdatesForToday()
                }
                
                if self.stepCounts.count == 8 {
                    self.stepCounts.sort({$0.date.timeIntervalSinceDate($1.date) > 0})
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                    let delay = 0.1
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
                    dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                        self.countLabel.countFrom(0.0, to: Float(self.numberOfStepsToday), withDuration: self.animationConstant)
                    })
                        self.finishedLoadingHistoricalStepData = true
                        self.tableView.reloadData()
                    })
                }
            })
        }
    }
    
    func startPedometerUpdatesForToday() {
        if !CMStepCounter.isStepCountingAvailable() {
            return
        }
        
        stepCounter.startStepCountingUpdatesToQueue(NSOperationQueue(), updateOn: 1) { (newSteps, date, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let totalSteps = self.numberOfStepsEarlierToday + newSteps
                self.numberOfStepsToday = totalSteps
                if self.numberOfCellsAnimated >= self.maxNumberOfCellsVisible {
                    self.countLabel.text = totalSteps.formattedString()
                }
                
                if self.stepCounts.count > 0 {
                    let stepInfo = self.stepCounts[0]
                    
                    if totalSteps > self.maxNumberOfSteps {
                        stepInfo.numberOfSteps = totalSteps
                        self.maxNumberOfSteps = totalSteps
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                    } else if totalSteps != stepInfo.numberOfSteps {
                        stepInfo.numberOfSteps = totalSteps
                        if self.tableView.numberOfRowsInSection(0) > 0 {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                            })
                        }
                    }
                }
            })
        }
        
    }
    
    func stopPedometerUpdatesForToday() {
        stepCounter.stopStepCountingUpdates()
    }
    
    func reloadStepData() {
        stopPedometerUpdatesForToday()
        loadHistoricalStepData()
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        if stepCounts.count > 0 && stepCounts[0].date.beginningOfDay() != NSDate().beginningOfDay() {
            reloadStepData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !CMStepCounter.isStepCountingAvailable() {
            return
        }
        
        if !CGRectEqualToRect(gradient.frame, headerView.bounds) {
            gradient.frame = headerView.bounds
        }
        
        if tableView.contentInset.top != CGRectGetHeight(headerView.frame) {
            let insets = UIEdgeInsetsMake(CGRectGetHeight(headerView.frame), 0, 0, 0)
            tableView.scrollIndicatorInsets = insets
            tableView.contentInset = insets
            tableView.contentOffset = CGPointMake(0, -CGRectGetHeight(headerView.frame))
        }
}

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finishedLoadingHistoricalStepData ? stepCounts.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as StepCell
        cell.backgroundColor = blueBackgroundColor
        
        let stepInfo = stepCounts[indexPath.row]
        cell.dayLabel.text = stepInfo.weekdayString
        cell.selectionStyle = .None
        
        
        var width: CGFloat = CGFloat(stepInfo.numberOfSteps) / CGFloat(maxNumberOfSteps)
        if maxNumberOfSteps == 0 {
            width = 0
        }
        
        if numberOfCellsAnimated < maxNumberOfCellsVisible {
            cell.countLabel.countFrom(0, to: Float(stepInfo.numberOfSteps), withDuration: animationConstant)
            cell.setBarWidth(width, animated: true)
            numberOfCellsAnimated++
        } else {
            cell.countLabel.text = Int(stepInfo.numberOfSteps).formattedString()
            cell.setBarWidth(width, animated: false)
        }
        
        cell.accessibilityLabel = stepInfo.description
        
        return cell
    }
}

extension Int {
    func formattedString() -> String {
        
        if self < 1000 && self > -1000 {
            return "\(self)"
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let numberFormatter = appDelegate.numberFormatter

        
        numberFormatter.groupingSeparator = NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleGroupingSeparator) as NSString
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        return numberFormatter.stringFromNumber(self)!
    }
}

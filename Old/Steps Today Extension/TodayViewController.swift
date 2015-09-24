//
//  TodayViewController.swift
//  Steps Today Extension
//
//  Created by Adam Binsz on 9/25/14.
//  Copyright (c) 2014 Adam Binsz. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreMotion

@objc(TodayViewController)

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let pedometer = CMPedometer()
    var numberFormatter: NSNumberFormatter!
    var todayLabel: UILabel!
    var countLabel: UILabel!
    var numberOfSteps: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "viewTapped:")
        view.addGestureRecognizer(gestureRecognizer)
        
        if !CMPedometer.isStepCountingAvailable() {
            
            let sorryLabel = UILabel(frame: CGRectZero)
            sorryLabel.font = UIFont(name: "HelveticaNeue", size: 15.5)
            sorryLabel.numberOfLines = 2
            sorryLabel.textColor = UIColor.whiteColor()
            sorryLabel.textAlignment = .Center
            sorryLabel.text = "Steps works only on the iPhone 5s, iPhone 6, and iPhone 6 Plus."
            sorryLabel.adjustsFontSizeToFitWidth = false
        
            let effectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
            effectView.contentView.addSubview(sorryLabel)
            view.addSubview(effectView)
            
            sorryLabel.translatesAutoresizingMaskIntoConstraints = false
            effectView.translatesAutoresizingMaskIntoConstraints = false
            effectView.contentView.translatesAutoresizingMaskIntoConstraints = false
            
            
            let labelInset: CGFloat = 20
            view.addConstraint(NSLayoutConstraint(item: sorryLabel, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: view, attribute: .Width, multiplier: 1.0, constant: labelInset * -2))
            
            view.addConstraint(NSLayoutConstraint(item: effectView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: effectView, attribute: .Width, relatedBy: .Equal, toItem: sorryLabel, attribute: .Width, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: effectView, attribute: .Height, relatedBy: .Equal, toItem: sorryLabel, attribute: .Height, multiplier: 1.0, constant: 0.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-24-[effectView]-24-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["effectView" : effectView]))
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["contentView" : effectView.contentView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["contentView" : effectView.contentView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sorryLabel]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sorryLabel" : sorryLabel]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sorryLabel]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["sorryLabel" : sorryLabel]))
            
            return
        }
        
        preferredContentSize = CGSizeZero
        
        numberFormatter = NSNumberFormatter()
        numberFormatter.groupingSeparator = NSLocale.autoupdatingCurrentLocale().objectForKey(NSLocaleGroupingSeparator) as? String ?? ""
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        
        let screenWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        var fontSize: CGFloat = 60
        if screenWidth > 375 {
            fontSize = 72
        } else if screenWidth > 320 {
            fontSize = 64
        }
        
        countLabel = UILabel(frame: CGRectZero)
        countLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: fontSize)
        countLabel.textColor = UIColor.whiteColor()
        countLabel.textAlignment = .Left
        if let steps = loadSavedSteps() {
            countLabel.text = numberFormatter.stringFromNumber(steps)
        } else {
            countLabel.text = " "
        }
        
        view.addSubview(countLabel)
        countLabel.sizeToFit()
        var f = countLabel.frame
        f.size.width = CGRectGetWidth(view.frame)
        countLabel.frame = f
        
        fontSize = 19
        if screenWidth > 375 {
            fontSize = 22
        } else if screenWidth > 320 {
            fontSize = 20
        }
        
        todayLabel = UILabel(frame: CGRectZero)
        todayLabel.font = UIFont(name: "HelveticaNeue-Light", size: fontSize)
        todayLabel.textColor = UIColor.whiteColor()
        todayLabel.textAlignment = .Left
        todayLabel.text = "Steps Today"
        
        var padding: CGFloat = 4
        if screenWidth > 375 {
            padding = 3
        }
        
        let effectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
        effectView.contentView.addSubview(todayLabel)
        todayLabel.sizeToFit()
        effectView.frame = CGRectMake(0, CGRectGetMaxY(countLabel.frame) - padding, CGRectGetWidth(todayLabel.frame), CGRectGetHeight(todayLabel.frame))
        view.addSubview(effectView)
        
        preferredContentSize = CGSizeMake(0, CGRectGetMaxY(effectView.frame))
        
        startPedometerUpdatesForToday()
    }
    
    func timeChangedSignificantly(notification: NSNotification) {
        pedometer.stopPedometerUpdates()
        countLabel.text = "0"
        startPedometerUpdatesForToday()
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        if !CMPedometer.isStepCountingAvailable() {
            return UIEdgeInsetsZero
        } else {
            return defaultMarginInsets
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "timeChangedSignificantly:", name: UIApplicationSignificantTimeChangeNotification, object: nil);
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationSignificantTimeChangeNotification, object: nil)
        
        saveSteps(numberOfSteps)
        pedometer.stopPedometerUpdates()
    }
    
    func startPedometerUpdatesForToday() {
        if !CMPedometer.isStepCountingAvailable() {
            return
        }
        pedometer.startPedometerUpdatesFromDate(NSDate.beginningOfToday(), withHandler: { (pedometerData, error) -> Void in
            if let data = pedometerData {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.numberOfSteps = data.numberOfSteps.integerValue
                    self.countLabel.text = self.numberFormatter.stringFromNumber(self.numberOfSteps)
                })
            } else {
                self.countLabel.text = "0"
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> ())) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if !CMPedometer.isStepCountingAvailable() {
            completionHandler(.NoData)
            return
        }
        
        pedometer.queryPedometerDataFromDate(NSDate.beginningOfToday(), toDate: NSDate()) { (pedometerData, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let _ = error {
                    completionHandler(NCUpdateResult.Failed)
                }
                
                if let pedometerData = pedometerData {
                    self.saveSteps(pedometerData.numberOfSteps.integerValue)
                    let countString = self.numberFormatter.stringFromNumber(pedometerData.numberOfSteps)
                    if countString != self.countLabel.text {
                        self.countLabel.text = countString
                        completionHandler(NCUpdateResult.NewData)
                    } else {
                        completionHandler(NCUpdateResult.NoData)
                    }
                }
            })
            
        }
    }
    
    func saveSteps(steps: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(steps, forKey: "latestNumberOfSteps")
        defaults.setObject(NSDate.beginningOfToday(), forKey: "latestStepsDate")
        defaults.synchronize()
    }
    
    func loadSavedSteps() -> Int? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let date = defaults.objectForKey("latestStepsDate") as? NSDate
        
        if let day = date {
            if day.isEqualToDate(NSDate.beginningOfToday()) {
                return defaults.integerForKey("latestNumberOfSteps")
            }
        }
        return nil
    }
    
    func viewTapped(gestureRecognizer: UIGestureRecognizer) {
        let url = NSURL(string: "stepsadambinsz://")
        extensionContext?.openURL(url!, completionHandler: nil)
    }
}

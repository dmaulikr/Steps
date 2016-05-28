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
import Crashlytics
import GoogleMobileAds

enum AdRefreshRate: String {
    case Short, Long
    var adUnitID: String {
        get {
            switch self {
            case .Short:
                return "ca-app-pub-3773029771274898/8438387761"
            case .Long:
                return "ca-app-pub-3773029771274898/7042379768"
            }
        }
    }
}

class ViewController: UIViewController, StoreObserver, GADBannerViewDelegate, GADAdSizeDelegate {

    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let stackView = OAStackView()
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var dayViews = [DayView]()
    
    private var store = Store(numberOfDays: 8)
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    private let stepCountFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        return numberFormatter
    }()
    
    private let distanceFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()

    private var showDistances: Bool {
        get {
            return self.segmentedControl.selectedSegmentIndex > 0
        }
    }

    let adRefreshRate: AdRefreshRate = arc4random() % 2 == 0 ? .Long : .Short
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var adView: GADBannerView!
    
    @IBOutlet weak var showAdConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideAdConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.registerObserver(self)
        
        let todayFormatter = NSDateFormatter()
        todayFormatter.dateStyle = .ShortStyle
        todayFormatter.timeStyle = .NoStyle
        todayFormatter.doesRelativeDateFormatting = true
        todayLabel.text = todayFormatter.stringFromDate(NSDate())
        
        gradientView.topColor = UIColor(red: 29.0/255.0, green: 97.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        gradientView.bottomColor = UIColor(red: 25.0/255.0, green: 213.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        
        segmentedControl.alpha = 0.0
        segmentedControl.setTitle(Settings.useMetric ? "km" : "mi", forSegmentAtIndex: 1)
        
        stackView.distribution = .FillEqually
        stackView.axis = .Vertical
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activateConstraints(stackView.constraintsWithAttributes([.Top, .Left, .Right, .Width, .Bottom], .Equal, to: scrollView))
        stackView.constraintWithAttribute(.Height, .GreaterThanOrEqual, to: scrollView).active = true
        
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: Settings.useMetricKey, options: [.New], context: nil)
    
        for direction in [.Left, .Right] as [UISwipeGestureRecognizerDirection] {
            let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.viewSwiped(_:)))
            swipeGestureRecognizer.direction = direction
            scrollView.addGestureRecognizer(swipeGestureRecognizer)
        }
        
        adView.adSize = kGADAdSizeSmartBannerPortrait
        adView.delegate = self
        adView.adSizeDelegate = self
        adView.rootViewController = self
        adView.adUnitID = adRefreshRate.adUnitID
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID /*, "224ddf7740ce4fb20d147d9a7d6d52c9"*/]
        adView.loadRequest(request)
        
        Answers.logCustomEventWithName("AdMob Refresh Rate", customAttributes: ["Rate" : adRefreshRate.rawValue])
        
//        let timer = NSTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.testAd), userInfo: nil, repeats: true)
//        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    override func viewDidAppear(animated: Bool) {
        store.fetchSteps()
        
        if Store.authorizationStatusForType(HKQuantityType.stepCount) == .NotDetermined && self.presentedViewController == nil {
            showPermissionViewController()
        }
    }
    
    func showPermissionViewController() {
        let permissionViewController = PermissionViewController.loadFromStoryboard()
        permissionViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(permissionViewController, animated: true, completion: nil)
    }
    
    func viewSwiped(gestureRecognizer: UISwipeGestureRecognizer) {
        var index = segmentedControl.selectedSegmentIndex
        switch gestureRecognizer.direction {
        case UISwipeGestureRecognizerDirection.Left:
           index += 1
        case UISwipeGestureRecognizerDirection.Right:
           index -= 1
        default:
            break
        }
        
        if index < 0 || index >= segmentedControl.numberOfSegments { return }
        segmentedControl.selectedSegmentIndex = index
        self.unitSegmentedControlValueChanged(segmentedControl)
    }
    
    func testAd() {
//        setBannerAdHidden(!bannerHidden, animated: true)
//        if !bannerHidden {
//            let size = GADAdSize(size: CGSize(width: CGFloat(rand() % 800), height: CGFloat(rand() % 1000)), flags: 0)
//            adView(adView, willChangeAdSizeTo: size)
//        }
        
//        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID, "224ddf7740ce4fb20d147d9a7d6d52c9"]
//        adView.loadRequest(request)
    }
    
    private func updateTodayLabel() {
        guard let firstStepCount = store.steps?.first else { return }
        
        let count: Double = self.showDistances ? (firstStepCount.distanceInPreferredUnit ?? 0) : Double((firstStepCount.count ?? 0))
        let formatter = self.showDistances ? distanceFormatter : stepCountFormatter
        countLabel.text = formatter.stringFromNumber(count)
    }
    
    private var updatingChart = false
    private func updateChart(animated animated: Bool = false) {
        guard let stepCounts = store.steps where !updatingChart else { return }
        segmentedControl.alpha = 1.0
        updatingChart = true
        
        if dayViews.count < stepCounts.count {
            layoutChart(stepCounts.count)
        }
        
        for index in 0..<stepCounts.count {
            updateBarAtIndex(index, animated: animated)
        }
        updatingChart = false
    }
    
    private func layoutChart(numberOfEntries: Int) {
        while dayViews.count < numberOfEntries {
            let dayView = DayView.loadFromNib()
            dayView.addConstraint(NSLayoutConstraint(item: dayView,
                attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1.0,
                constant: 54)
            )
            
            stackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func updateBarAtIndex(index: Int, animated: Bool) {
        guard let stepCounts = store.steps,
            stepCount = stepCounts[safe: index],
            dayView = dayViews[safe: index]
            else { return }
        
        dayView.dayLabel.text = dateFormatter.stringFromDate(stepCount.date)
        dayView.countLabel.text = self.showDistances ? self.distanceFormatter.stringFromNumber(stepCount.distanceInPreferredUnit ?? 0) : self.stepCountFormatter.stringFromNumber(stepCount.count ?? 0)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let duration = animated ? 0.88 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            dayView.barScale = max(CGFloat(stepCount.count ??  0) / CGFloat(self.store.maxStepCount), 0.015)
        }, completion: nil)
    }
    
    @IBAction func unitSegmentedControlValueChanged(sender: UISegmentedControl) {
        self.updateTodayLabel()
        self.updateChart()
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let path = keyPath where path == Settings.useMetricKey else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if self.showDistances {
            Async.main {
                self.updateTodayLabel()
                self.updateChart()
            }
        }
        
        var attributes = [String: String]()
        attributes["from"] = self.segmentedControl.titleForSegmentAtIndex(1)
        self.segmentedControl.setTitle(Settings.useMetric ? "km" : "mi", forSegmentAtIndex: 1)
        attributes["to"] = self.segmentedControl.titleForSegmentAtIndex(1)
        
        Answers.logCustomEventWithName("Unit Change", customAttributes: attributes)
    }
    
    
    // MARK: - GADBannerView delegate methods
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
//        print(#function)
        Answers.logCustomEventWithName("AdMob Ad Loaded", customAttributes: nil)
        setBannerAdHidden(false, animated: true)
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
//        print(#function)
//        print(error)
        Answers.logErrorWithName("AdMob Ad Error", error: error)
        setBannerAdHidden(true, animated: true)
    }
    
    func adViewWillPresentScreen(bannerView: GADBannerView!) {
//        print(#function)
        Answers.logCustomEventWithName("AdMob Presenting Screen", customAttributes: nil)
    }
    
    
    func adViewWillLeaveApplication(bannerView: GADBannerView!) {
//        print(#function)
        Answers.logCustomEventWithName("AdMob Leaving Application", customAttributes: nil)
    }
    
    func adView(bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        Answers.logCustomEventWithName("AdMob Ad Size Change", customAttributes: ["width": size.size.width, "height": size.size.height])
    }
    
    private var bannerHidden = true
    func setBannerAdHidden(hidden: Bool, animated: Bool = false) {
    
        if bannerHidden == hidden { return }
        bannerHidden = hidden
        
//        adView.setNeedsLayout()
//        adView.layoutIfNeeded()
        
        showAdConstraint.priority = hidden ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        hideAdConstraint.priority = hidden ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
        view.setNeedsLayout()
        
        let duration = animated ? 0.15 : 0.0
        UIView.animateWithDuration(duration, delay: 0.0, options: [.BeginFromCurrentState], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - StepsStoreObserver methods
    func storeDidUpdateType(type: HKObjectType) {
        Async.main {
            self.updateTodayLabel()
            self.updateChart(animated: self.dayViews.count == 0)
        }
    }
    
    var errorShown = false
    var alertController: UIAlertController?
    var alertTypes = [HKQuantityType]()
    func alertMessageForTypes(types: [HKQuantityType]) -> String {
        
        let stepCounts = types.contains(HKQuantityType.stepCount)
        let distances = types.contains(HKQuantityType.distanceWalkingRunning)
        
        var typesString = "step counts"
        var sectionsString = "‘Steps’"
        
        if stepCounts && distances {
            typesString = "step counts and distances"
            sectionsString = "both ‘Steps’ and ‘Walking + Running Distance’"
        } else if distances {
            typesString = "distances"
            sectionsString = "‘Walking + Running Distance’"
        }
        
        return "Steps isn't receiving \(typesString) from your iPhone. Open the Settings app, then go to Privacy > Health > Steps and turn on \(sectionsString)."
    }
    
    func showErrorAlertControllerForType(type: HKQuantityType) {
        if alertController == nil {
            alertController = UIAlertController(title: "Having trouble?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.store.fetchSteps()
                self.alertController = nil
                self.alertTypes = [HKQuantityType]()
            })
            
            alertController?.addAction(OKAction)
            Async.main { self.presentViewController(self.alertController!, animated: true, completion: nil) }
        }
        
        guard let alertController = alertController else { return }
        alertTypes.append(type)
        alertController.message = alertMessageForTypes(alertTypes)
    }
    
    func storeDidFailUpdatingType(type: HKQuantityType, error: NSError) {
        
        Answers.logErrorWithName("Steps Update Error", error: error)
        
        if error.domain == HKErrorDomain && self.presentedViewController == nil {
            Async.main { self.showPermissionViewController() }
        } else {
            if dayViews.count == 0 {
                Async.main {
                    self.updateTodayLabel()
                    self.updateChart(animated: self.dayViews.count == 0)
                }
            }
            
            if let error = (error as ErrorType) as? StoreError where error == .NoDataReturned && (alertController != nil || !errorShown) {
                showErrorAlertControllerForType(type)
                errorShown = true
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

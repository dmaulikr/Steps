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

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let stackView = OAStackView()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var settingsButton: UIButton!
    
    fileprivate var dayViews = [DayView]()
    
    fileprivate var store = Store(numberOfDays: 8)
    
    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    fileprivate let stepCountFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        return numberFormatter
    }()
    
    fileprivate let distanceFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()

    fileprivate var showDistances: Bool {
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
        
        let todayFormatter = DateFormatter()
        todayFormatter.dateStyle = .short
        todayFormatter.timeStyle = .none
        todayFormatter.doesRelativeDateFormatting = true
        todayLabel.text = todayFormatter.string(from: Date())
        
        if let gradientView = view as? GradientView {
            gradientView.topColor = UIColor.blueGradientTopColor
            gradientView.bottomColor = UIColor.blueGradientBottomColor
        }
        
        segmentedControl.alpha = 0.0
        segmentedControl.setTitle(Settings.useMetric ? "km" : "mi", forSegmentAt: 1)
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate(stackView.constraintsWithAttributes([.top, .left, .right, .width, .bottom], .equal, to: scrollView))
        stackView.constraintWithAttribute(.height, .greaterThanOrEqual, to: scrollView).isActive = true
        
        Settings.defaults.addObserver(self, forKeyPath: Settings.useMetricKey, options: [.new], context: nil)
    
        for direction in [.left, .right] as [UISwipeGestureRecognizerDirection] {
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
        adView.load(request)
        
        if let image = settingsButton.currentImage {
            settingsButton.setImage(image.withRenderingMode(.alwaysTemplate), for: UIControlState())
        }
        
        Answers.logCustomEvent(withName: "AdMob Refresh Rate", customAttributes: ["Rate" : adRefreshRate.rawValue])
        
//        let timer = NSTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.testAd), userInfo: nil, repeats: true)
//        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        store.fetchSteps()
        
        if Store.authorizationStatusForType(HKQuantityType.stepCount) == .notDetermined && self.presentedViewController == nil {
            showPermissionViewController()
        }
    }
    
    func showPermissionViewController() {
        let permissionViewController = PermissionViewController.loadFromStoryboard()
        permissionViewController.modalTransitionStyle = .crossDissolve
        present(permissionViewController, animated: true, completion: nil)
    }
    
    func viewSwiped(_ gestureRecognizer: UISwipeGestureRecognizer) {
        var index = segmentedControl.selectedSegmentIndex
        switch gestureRecognizer.direction {
        case UISwipeGestureRecognizerDirection.left:
           index += 1
        case UISwipeGestureRecognizerDirection.right:
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
    
    fileprivate func updateTodayLabel() {
        guard let firstStepCount = store.steps?.first else { return }
        
        let count: Double = self.showDistances ? (firstStepCount.distanceInPreferredUnit ?? 0) : Double((firstStepCount.count ?? 0))
        let formatter = self.showDistances ? distanceFormatter : stepCountFormatter
        countLabel.text = formatter.string(from: NSNumber(value: count))
    }
    
    fileprivate var updatingChart = false
    fileprivate func updateChart(animated: Bool = false) {
        guard let stepCounts = store.steps , !updatingChart else { return }
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
    
    fileprivate func layoutChart(_ numberOfEntries: Int) {
        while dayViews.count < numberOfEntries {
            let dayView = DayView.loadFromNib()
            dayView.addConstraint(NSLayoutConstraint(item: dayView,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: 54)
            )
            
            stackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    fileprivate func updateBarAtIndex(_ index: Int, animated: Bool) {
        guard let stepCounts = store.steps,
            let stepCount = stepCounts[safe: index],
            let dayView = dayViews[safe: index]
            else { return }
        
        dayView.dayLabel.text = dateFormatter.string(from: stepCount.date as Date)
        dayView.countLabel.text = self.showDistances ? self.distanceFormatter.string(from: stepCount.distanceInPreferredUnit as NSNumber? ?? 0) : self.stepCountFormatter.string(from: stepCount.count as NSNumber? ?? 0)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let duration = animated ? 0.88 : 0.0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
            let scale = self.store.maxStepCount > 0 ? CGFloat(stepCount.count ??  0) / CGFloat(self.store.maxStepCount) : 0
            dayView.barScale = max(scale, 0.015)
        }, completion: nil)
    }
    
    @IBAction func unitSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.updateTodayLabel()
        self.updateChart()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let path = keyPath , path == Settings.useMetricKey else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if self.showDistances {
            DispatchQueue.main.async {
                self.updateTodayLabel()
                self.updateChart()
            }
        }
        
        var attributes = [String: String]()
        attributes["from"] = self.segmentedControl.titleForSegment(at: 1)
        self.segmentedControl.setTitle(Settings.useMetric ? "km" : "mi", forSegmentAt: 1)
        attributes["to"] = self.segmentedControl.titleForSegment(at: 1)
        
        Answers.logCustomEvent(withName: "Unit Change", customAttributes: attributes)
    }
    
    
    // MARK: - GADBannerView delegate methods
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
//        print(#function)
        Answers.logCustomEvent(withName: "AdMob Ad Loaded", customAttributes: nil)
        setBannerAdHidden(false, animated: true)
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
//        print(#function)
//        print(error)
        Answers.logErrorWithName("AdMob Ad Error", error: error)
        setBannerAdHidden(true, animated: true)
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView!) {
//        print(#function)
        Answers.logCustomEvent(withName: "AdMob Presenting Screen", customAttributes: nil)
    }
    
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView!) {
//        print(#function)
        Answers.logCustomEvent(withName: "AdMob Leaving Application", customAttributes: nil)
    }
    
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        Answers.logCustomEvent(withName: "AdMob Ad Size Change", customAttributes: ["width": size.size.width, "height": size.size.height])
    }
    
    fileprivate var bannerHidden = true
    func setBannerAdHidden(_ hidden: Bool, animated: Bool = false) {
    
        if bannerHidden == hidden { return }
        bannerHidden = hidden
        
//        adView.setNeedsLayout()
//        adView.layoutIfNeeded()
        
        showAdConstraint.priority = hidden ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        hideAdConstraint.priority = hidden ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
        view.setNeedsLayout()
        
        let duration = animated ? 0.15 : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: [.beginFromCurrentState], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - StepsStoreObserver methods
    func storeDidUpdateType(_ type: HKObjectType) {
        DispatchQueue.main.sync {
            self.updateTodayLabel()
            self.updateChart(animated: self.dayViews.count == 0)
        }
    }
    
    var errorShown = false
    var alertController: UIAlertController?
    var alertTypes = [HKQuantityType]()
    func alertMessageForTypes(_ types: [HKQuantityType]) -> String {
        
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
    
    func showErrorAlertControllerForType(_ type: HKQuantityType) {
        if alertController == nil {
            alertController = UIAlertController(title: "Having trouble?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.store.fetchSteps()
                self.alertController = nil
                self.alertTypes = [HKQuantityType]()
            })
            
            alertController?.addAction(OKAction)
            DispatchQueue.main.sync { self.present(self.alertController!, animated: true, completion: nil) }
        }
        
        guard let alertController = alertController else { return }
        alertTypes.append(type)
        alertController.message = alertMessageForTypes(alertTypes)
    }
    
    func storeDidFailUpdatingType(_ type: HKQuantityType, error: NSError) {
        
        Answers.logErrorWithName("Steps Update Error", error: error)
        
        if error.domain == HKErrorDomain && self.presentedViewController == nil {
            DispatchQueue.main.sync { self.showPermissionViewController() }
        } else {
            if dayViews.count == 0 {
                DispatchQueue.main.sync {
                    self.updateTodayLabel()
                    self.updateChart(animated: self.dayViews.count == 0)
                }
            }
            
            if let error = (error as Error) as? StoreError , error == .noDataReturned && (alertController != nil || !errorShown) {
                showErrorAlertControllerForType(type)
                errorShown = true
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

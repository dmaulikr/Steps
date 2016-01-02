//
//  TodayViewController.swift
//  Steps Today Extension
//
//  Created by Adam Binsz on 12/13/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit
import HealthKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, StoreObserver {
    
    private let stepCountFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        return numberFormatter
    }()
    
    private let store = Store(numberOfDays: 1)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        store.registerObserver(self)
        store.fetchSteps()
    }
    
    @IBOutlet weak var stepsLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let types: Set<HKQuantityType> = [HKQuantityType.stepCount, HKQuantityType.distanceWalkingRunning]
        HKHealthStore().requestAuthorizationToShareTypes(nil, readTypes: types) { authorized, error in
            print(error)
            print(authorized)
        }
        
        updateLabel()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    private func updateLabel() {
        self.stepsLabel?.text = stepCountFormatter.stringFromNumber(store.steps?.first?.count ?? 0)
    }
    
    // MARK: - StoreObserver methods
    func storeDidUpdateType(type: HKObjectType) {
        updateLabel()
    }
    
    func storeDidFailUpdatingType(type: HKQuantityType, error: NSError) {
        print(error)
    }
}

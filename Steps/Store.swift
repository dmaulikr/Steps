//
//  Store.swift
//  Steps
//
//  Created by Adam Binsz on 11/28/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import HealthKit
import SwiftDate

@objc protocol StoreObserver {
    func storeDidUpdateType(_ type: HKObjectType)
    func storeDidFailUpdatingType(_ type: HKQuantityType, error: NSError)
}

enum StoreError: Error {
    case noDataReturned
}

class Store: NSObject {
    static fileprivate let healthStore = HKHealthStore()
    static func authorizationStatusForType(_ type: HKObjectType) -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: type)
    }
    
    fileprivate let numberOfDays: Int
    fileprivate var stepsDict = [Date: Step]() {
        didSet {
            self.steps = [Step](stepsDict.values).sorted{ $0.date.timeIntervalSince($1.date as Date) > 0 }
        }
    }
    private(set) var steps: [Step]?
    var maxStepCount: Int {
        get { return stepsDict.values.map{ $0.count ?? 0 }.max() ?? 0 }
    }
    fileprivate var activeQueries = [HKQuery]()
    fileprivate var observers = [WeakContainer<StoreObserver>]()
    
    init(numberOfDays: Int = 8) {
        self.numberOfDays = numberOfDays
        super.init()
        NotificationCenter.default.addObserver(self,
            selector: #selector(Store.significantTimeChange),
            name: NSNotification.Name(rawValue: AppDelegate.significantTimeChangeNotificationName),
            object: nil)
    }
    
    func significantTimeChange() {
        fetchSteps()
    }
    
    func fetchSteps() {
        guard numberOfDays > 0 else { return }
        
        stopActiveQueries()
        
        let today = Date().startOf(component: .day)
        var dates = [Date]()
        
        var newDict = [Date: Step]()
        for index in 0..<numberOfDays {
            let date = today.add(days: -index)
            dates.append(date)
            newDict[date] = stepsDict[date] ?? Step(date: date)
        }
        stepsDict = newDict
        
        let stepsQuery = self.stepsQuery(dates)
        Store.healthStore.execute(stepsQuery)
        activeQueries.append(stepsQuery)
        
        let distancesQuery = self.distancesQuery(dates)
        Store.healthStore.execute(distancesQuery)
        activeQueries.append(distancesQuery)
    }
    
    fileprivate func stepsQuery(_ dates: [Date]) -> HKQuery {
        let stepCountHandler: DailySumHandler = { dates, statisticsCollection, error in
            
            defer {
                if error != nil || statisticsCollection == nil || statisticsCollection!.statistics().count == 0 {
                    for observer in self.observers {
                        observer.value?.storeDidFailUpdatingType(HKQuantityType.stepCount, error: error as NSError? ?? StoreError.noDataReturned as NSError)
                    }
                } else {
                    for observer in self.observers {
                        observer.value?.storeDidUpdateType(HKQuantityType.stepCount)
                    }
                }
            }
            
            for date in dates {
                if self.stepsDict[date] == nil {
                    self.stepsDict[date] = Step(date: date)
                }
                
                guard let sum = statisticsCollection?.statistics(for: date)?.sumQuantity()?.doubleValue(for: HKUnit.count()) else { continue }
                let roundedSum = Int(floor(sum))
                self.stepsDict[date]?.count = roundedSum
            }
        }
        
        return HKQuery.dailySumQueryForQuantityType(HKQuantityType.stepCount, dates: dates, resultsHandler: stepCountHandler, updateHandler: stepCountHandler, errorHandler: nil)
    }
    
    fileprivate func distancesQuery(_ dates: [Date]) -> HKQuery {
        let distanceHandler: DailySumHandler = { dates, statisticsCollection, error in
            
            defer {
                if error != nil || statisticsCollection == nil || statisticsCollection!.statistics().count == 0 {
                    for observer in self.observers {
                        observer.value?.storeDidFailUpdatingType(HKQuantityType.distanceWalkingRunning, error: error as NSError? ?? StoreError.noDataReturned as NSError)
                    }
                } else {
                    for observer in self.observers {
                        observer.value?.storeDidUpdateType(HKQuantityType.distanceWalkingRunning)
                    }
                }
            }
            
            for date in dates {
                if self.stepsDict[date] == nil {
                    self.stepsDict[date] = Step(date: date)
                }
                
                guard let sumQuantity = statisticsCollection?.statistics(for: date)?.sumQuantity() else { continue }
                self.stepsDict[date]?.distance = sumQuantity
            }
        }
        
        return HKQuery.dailySumQueryForQuantityType(HKQuantityType.distanceWalkingRunning, dates: dates, resultsHandler: distanceHandler, updateHandler: distanceHandler, errorHandler: nil)
    }
    
    func stopActiveQueries() {
        for query in activeQueries {
            Store.healthStore.stop(query)
        }
    }
    
    // MARK: - StepsStoreObserver management methods
    func registerObserver(_ observer: StoreObserver) {
        for existing in observers {
            if existing.value === observer {
                return
            }
        }
        
        observers.append(WeakContainer(value: observer))
    }
    
    func unregisterObserver(_ observer: StoreObserver) {
        for (index, existing) in observers.enumerated() {
            if existing.value === observer {
                observers.remove(at: index)
                return
            }
        }
    }
}

private typealias DailySumHandler = ((_ dates: [Date], _ statisticsCollection: HKStatisticsCollection?, _ error: Error?) -> ())

private extension HKQuery {
    static func dailySumQueryForQuantityType(_ quantityType: HKQuantityType, dates: [Date], resultsHandler: DailySumHandler?, updateHandler: DailySumHandler?, errorHandler: ((_ error: Error) -> ())?) -> HKQuery {
        
        let sortedDates = dates.sorted{ $0.timeIntervalSince($1) > 0 }
        
        var intervalComponents = DateComponents()
        intervalComponents.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: sortedDates.last, end: sortedDates.first?.endOf(component: .day), options: [])
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: Date().startOf(component: .day), intervalComponents: intervalComponents)
        
        query.initialResultsHandler = { query, statisticsCollection, error in
            resultsHandler?(dates, statisticsCollection, error)
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            updateHandler?(dates, statisticsCollection, error)
        }
        
        return query
    }
}

//
//  Store.swift
//  Steps
//
//  Created by Adam Binsz on 11/28/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import HealthKit
import SwiftDate

let significantTimeChangeNotificationName = "significantTimeChange"

@objc protocol StoreObserver {
    func storeDidUpdateType(type: HKObjectType)
    func storeDidFailUpdatingType(type: HKQuantityType, error: NSError)
}

enum StoreError: ErrorType {
    case NoDataReturned
}

class Store: NSObject {
    static private let healthStore = HKHealthStore()
    static func authorizationStatusForType(type: HKObjectType) -> HKAuthorizationStatus {
        return healthStore.authorizationStatusForType(type)
    }
    
    private let numberOfDays: Int
    private var stepsDict: [NSDate : Step]?
    var steps: [Step]? {
        get {
            guard let stepsDict = stepsDict else { return nil }
            return [Step](stepsDict.values).sort{ $0.date.timeIntervalSinceDate($1.date) > 0 }
        }
    }
    private(set) var maxStepCount: Int = 0
    private var activeQueries = [HKQuery]()
    private var observers = [WeakContainer<StoreObserver>]()
    
    init(numberOfDays: Int = 8) {
        self.numberOfDays = numberOfDays
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "significantTimeChange",
            name: significantTimeChangeNotificationName,
            object: nil)
    }
    
    func significantTimeChange() {
        fetchSteps()
    }
    
    func fetchSteps() {
        guard numberOfDays > 0 else { return }
        
        maxStepCount = 0
        stopActiveQueries()
        stepsDict = [NSDate : Step]()
        
        let today = NSDate().beginningOfDay
        var dates = (0..<numberOfDays).map{ today.add(days: -$0) }
        
        for index in 0..<numberOfDays {
            let date = today.add(days: -index)
            dates.append(date)
            stepsDict?[date] = Step(date: date)
        }
        
        let stepsQuery = self.stepsQuery(dates)
        Store.healthStore.executeQuery(stepsQuery)
        activeQueries.append(stepsQuery)
        
        let distancesQuery = self.distancesQuery(dates)
        Store.healthStore.executeQuery(distancesQuery)
        activeQueries.append(distancesQuery)
    }
    
    private func stepsQuery(dates: [NSDate]) -> HKQuery {
        let stepCountHandler: DailySumHandler = { dates, statisticsCollection, error in
            
            defer {
                if error != nil || statisticsCollection == nil || statisticsCollection!.statistics().count == 0 {
                    for observer in self.observers {
                        observer.value?.storeDidFailUpdatingType(HKQuantityType.stepCount, error: error ?? StoreError.NoDataReturned as NSError)
                    }
                } else {
                    for observer in self.observers {
                        observer.value?.storeDidUpdateType(HKQuantityType.stepCount)
                    }
                }
            }
            
            for date in dates {
                if self.stepsDict?[date] == nil {
                    self.stepsDict?[date] = Step(date: date)
                }
                
                guard let sum = statisticsCollection?.statisticsForDate(date)?.sumQuantity()?.doubleValueForUnit(HKUnit.countUnit()) else { continue }
                let roundedSum = Int(floor(sum))
                self.stepsDict?[date]?.count = roundedSum
                
                self.maxStepCount = max(self.maxStepCount, roundedSum)
            }
        }
        
        return HKQuery.dailySumQueryForQuantityType(HKQuantityType.stepCount, dates: dates, resultsHandler: stepCountHandler, updateHandler: stepCountHandler, errorHandler: nil)
    }
    
    private func distancesQuery(dates: [NSDate]) -> HKQuery {
        let distanceHandler: DailySumHandler = { dates, statisticsCollection, error in
            
            defer {
                if error != nil || statisticsCollection == nil || statisticsCollection!.statistics().count == 0 {
                    for observer in self.observers {
                        observer.value?.storeDidFailUpdatingType(HKQuantityType.distanceWalkingRunning, error: error ?? StoreError.NoDataReturned as NSError)
                    }
                } else {
                    for observer in self.observers {
                        observer.value?.storeDidUpdateType(HKQuantityType.distanceWalkingRunning)
                    }
                }
            }
            
            for date in dates {
                if self.stepsDict?[date] == nil {
                    self.stepsDict?[date] = Step(date: date)
                }
                
                guard let sumQuantity = statisticsCollection?.statisticsForDate(date)?.sumQuantity() else { continue }
                self.stepsDict?[date]?.distance = sumQuantity
            }
        }
        
        return HKQuery.dailySumQueryForQuantityType(HKQuantityType.distanceWalkingRunning, dates: dates, resultsHandler: distanceHandler, updateHandler: distanceHandler, errorHandler: nil)
    }
    
    func stopActiveQueries() {
        for query in activeQueries {
            Store.healthStore.stopQuery(query)
        }
    }
    
    // MARK: - StepsStoreObserver management methods
    func registerObserver(observer: StoreObserver) {
        for existing in observers {
            if existing.value === observer {
                return
            }
        }
        
        observers.append(WeakContainer(value: observer))
    }
    
    func unregisterObserver(observer: StoreObserver) {
        for (index, existing) in observers.enumerate() {
            if existing.value === observer {
                observers.removeAtIndex(index)
                return
            }
        }
    }
}

private typealias DailySumHandler = ((dates: [NSDate], statisticsCollection: HKStatisticsCollection?, error: NSError?) -> ())

private extension HKQuery {
    static func dailySumQueryForQuantityType(quantityType: HKQuantityType, dates: [NSDate], resultsHandler: DailySumHandler?, updateHandler: DailySumHandler?, errorHandler: ((error: ErrorType) -> ())?) -> HKQuery {
        
        let sortedDates = dates.sort{ $0.timeIntervalSinceDate($1) > 0 }
        
        let intervalComponents = NSDateComponents()
        intervalComponents.day = 1
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(sortedDates.last, endDate: sortedDates.first?.endOfDay, options: [])
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate().beginningOfDay, intervalComponents: intervalComponents)

        query.initialResultsHandler = { query, statisticsCollection, error in
            resultsHandler?(dates: dates, statisticsCollection: statisticsCollection, error: error)
        }
        
        query.statisticsUpdateHandler = { query, statistics, statisticsCollection, error in
            updateHandler?(dates: dates, statisticsCollection: statisticsCollection, error: error)
        }
        
        return query
    }
}

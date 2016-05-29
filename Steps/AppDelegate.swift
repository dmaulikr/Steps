//
//  AppDelegate.swift
//  Steps
//
//  Created by Adam Binsz on 9/22/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let significantTimeChangeNotificationName = "significantTimeChange"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Settings.initializeDefaults()
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func applicationSignificantTimeChange(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.significantTimeChangeNotificationName, object: nil)
    }


}


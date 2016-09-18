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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Settings.initializeDefaults()
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func applicationSignificantTimeChange(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppDelegate.significantTimeChangeNotificationName), object: nil)
    }


}


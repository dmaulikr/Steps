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
import Appodeal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let significantTimeChangeNotificationName = "significantTimeChange"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appodeal.initializeWithApiKey("6d77c98b651bffd73d54e908d230ad7c7d90f111512ee5c0", types: [.Banner]);
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func applicationSignificantTimeChange(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.significantTimeChangeNotificationName, object: nil)
    }


}


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
    
    static let significantTimeChangeNotificationName = "timeDidChangeSignificantly"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func applicationSignificantTimeChange(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.significantTimeChangeNotificationName, object: nil)
    }


}


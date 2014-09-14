//
//  AppDelegate.swift
//  Steps
//
//  Created by Adam Binsz on 8/27/14.
//  Copyright (c) 2014 Adam Binsz. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    let numberFormatter = NSNumberFormatter();

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        Flurry.startSession("QMNZG7MFC98DYMC4K5J6")
        Crashlytics.startWithAPIKey("ae0def216849ab79867b572dfd4978083ae3e060")
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let viewController = MainViewController()
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        
        if UIAccessibilityIsVoiceOverRunning() {
            Flurry.logEvent("Accessibility Enabled")
        }
        
        return true
    }
    
    func timeChanged(notification: NSNotification?) {
        let mainViewController = self.window?.rootViewController as MainViewController
        mainViewController.reloadStepData()
    }
    
    func voiceOverStatusChanged(notification: NSNotification) {
        if UIAccessibilityIsVoiceOverRunning() {
            Flurry.logEvent("Accessibility Enabled")
        }
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins trhe transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationSignificantTimeChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIAccessibilityVoiceOverStatusChanged, object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "timeChanged:", name: UIApplicationSignificantTimeChangeNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "voiceOverStatusChanged:", name: UIAccessibilityVoiceOverStatusChanged, object: nil);
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


//
//  AdViewController.swift
//  Steps
//
//  Created by Adam Binsz on 9/18/16.
//  Copyright © 2016 Adam Binsz. All rights reserved.
//

import UIKit
import Crashlytics
import GoogleMobileAds

class AdViewController: UIViewController, GADBannerViewDelegate, GADAdSizeDelegate {
    
    let adRefreshRate: AdRefreshRate = arc4random() % 2 == 0 ? .Long : .Short
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var adView: GADBannerView!
    
    @IBOutlet weak var showAdConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideAdConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        adView.adSize = kGADAdSizeSmartBannerPortrait
        adView.delegate = self
        adView.adSizeDelegate = self
        adView.rootViewController = self
        adView.adUnitID = adRefreshRate.adUnitID
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
}

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

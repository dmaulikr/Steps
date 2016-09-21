//
//  SettingsViewController.swift
//  Steps
//
//  Created by Adam Binsz on 5/28/16.
//  Copyright © 2016 Adam Binsz. All rights reserved.
//

import UIKit
import BRYXGradientView
import MessageUI
import Crashlytics
import GoogleMobileAds

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate, GADAdSizeDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var adView: GADBannerView!
    
    @IBOutlet weak var helpButton: UIButton!
    let unitSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        footerView.backgroundColor = tableView.backgroundColor
        
        unitSwitch.isOn = Settings.useMetric
        
        helpButton.titleLabel?.lineBreakMode = .byWordWrapping
        helpButton.titleLabel?.textAlignment = .center
        if !MFMailComposeViewController.canSendMail() {  helpButton.isEnabled = false }
        
        adView.adSize = kGADAdSizeSmartBannerPortrait
        adView.delegate = self
        adView.adSizeDelegate = self
        adView.rootViewController = self
        
        let adRefreshRate: AdRefreshRate = arc4random() % 2 == 0 ? .Long : .Short
        adView.adUnitID = adRefreshRate.adUnitID
        Answers.logCustomEvent(withName: "AdMob Refresh Rate", customAttributes: ["Rate" : adRefreshRate.rawValue])
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "98a094551a7e77990ccbfd3fcf409198"]
        adView.load(request)
        
        Answers.logCustomEvent(withName: "Settings Loaded", customAttributes: nil)
        Answers.logCustomEvent(withName: "Can Send Mail", customAttributes: ["canSendMail" : helpButton.isEnabled])
    }
    
    @IBAction func unitSwitchChanged(_ sender: AnyObject) {
        Settings.useMetric = unitSwitch.isOn
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath)
        guard let cell = c as? SwitchCell else { return c }
        cell.label.text = "Use Metric"
        cell.cellSwitch.isOn = Settings.useMetric
        cell.cellSwitch.addTarget(self, action: #selector(SettingsViewController.metricSwitchValueChanged(_:)), for: .valueChanged)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Units"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Use metric units for distances walked."
    }
    
    func metricSwitchValueChanged(_ sender: UISwitch) {
        Settings.useMetric = sender.isOn
    }
    
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["adam@adambinsz.com"])
        mailVC.setSubject("Steps Help")
        mailVC.setMessageBody("I'm having trouble with Steps:\n\n\n", isHTML: false)
        
        self.present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - GADBannerView delegate methods
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        //        print(#function)
        Answers.logCustomEvent(withName: "AdMob Settings Ad Loaded", customAttributes: nil)
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        //        print(#function)
        //        print(error)
        Answers.logErrorWithName("AdMob Ad Error", error: error)
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
}


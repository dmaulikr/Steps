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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerLabel: UILabel!
    
    @IBOutlet weak var helpButton: UIButton!
    let unitSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        footerView.backgroundColor = tableView.backgroundColor
        
        unitSwitch.on = Settings.useMetric
        
        helpButton.titleLabel?.lineBreakMode = .ByWordWrapping
        helpButton.titleLabel?.textAlignment = .Center
        if !MFMailComposeViewController.canSendMail() {  helpButton.enabled = false }
    }
    
    @IBAction func unitSwitchChanged(sender: AnyObject) {
        Settings.useMetric = unitSwitch.on
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath)
        guard let cell = c as? SwitchCell else { return c }
        cell.label.text = "Use Metric"
        cell.cellSwitch.on = Settings.useMetric
        cell.cellSwitch.addTarget(self, action: #selector(SettingsViewController.metricSwitchValueChanged(_:)), forControlEvents: .ValueChanged)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Units"
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Use metric units for distances walked."
    }
    
    func metricSwitchValueChanged(sender: UISwitch) {
        Settings.useMetric = sender.on
    }
    
    @IBAction func helpButtonPressed(sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailVC = MFMailComposeViewController()
        mailVC.delegate = self
        mailVC.setToRecipients(["adam@adambinsz.com"])
        mailVC.setSubject("Steps Help")
        mailVC.setMessageBody("I'm having trouble with Steps:\n", isHTML: false)
        
        self.presentViewController(mailVC, animated: true, completion: nil)
    }
}


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
        
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        footerView.backgroundColor = tableView.backgroundColor
        
        unitSwitch.isOn = Settings.useMetric
        
        helpButton.titleLabel?.lineBreakMode = .byWordWrapping
        helpButton.titleLabel?.textAlignment = .center
        if !MFMailComposeViewController.canSendMail() {  helpButton.isEnabled = false }
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
        mailVC.delegate = self
        mailVC.setToRecipients(["adam@adambinsz.com"])
        mailVC.setSubject("Steps Help")
        mailVC.setMessageBody("I'm having trouble with Steps:\n", isHTML: false)
        
        self.present(mailVC, animated: true, completion: nil)
    }
}


//
//  SettingsTableViewController.swift
//  Steps
//
//  Created by Adam Binsz on 5/28/16.
//  Copyright © 2016 Adam Binsz. All rights reserved.
//

import UIKit
import BRYXGradientView

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var unitSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitSwitch.on = Settings.useMetric
    }
    
    @IBAction func unitSwitchChanged(sender: AnyObject) {
        Settings.useMetric = unitSwitch.on
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

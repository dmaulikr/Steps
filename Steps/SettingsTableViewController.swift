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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

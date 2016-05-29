//
//  SettingsTableViewController.swift
//  Steps
//
//  Created by Adam Binsz on 5/28/16.
//  Copyright © 2016 Adam Binsz. All rights reserved.
//

import UIKit
import StoreKit
import BRYXGradientView

enum SettingsTableViewSection: Int {
    case Units, Upgrade
}

class SettingsTableViewController: UITableViewController, SKProductsRequestDelegate {
    
    @IBOutlet weak var unitSwitch: UISwitch!
    
    @IBOutlet weak var upgradeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static let numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        return numberFormatter
    }()
    
    var upgradeProduct: SKProduct? {
        didSet {
            tableView.reloadData()
            activityIndicator.stopAnimating()
            
            guard let upgradeProduct = upgradeProduct else { return }
            upgradeLabel.text = upgradeProduct.localizedTitle
            
            SettingsTableViewController.numberFormatter.locale = upgradeProduct.priceLocale
            priceLabel.text = SettingsTableViewController.numberFormatter.stringFromNumber(upgradeProduct.price)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitSwitch.on = Settings.useMetric
        
        requestProductInfo()
    }
    
    @IBAction func unitSwitchChanged(sender: AnyObject) {
        Settings.useMetric = unitSwitch.on
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard (indexPath.section, indexPath.row) == (1, 0) else { return }

    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return upgradeProduct == nil ? nil : indexPath
    }
    
    func requestProductInfo() {
        guard SKPaymentQueue.canMakePayments() else {
            print("Cannot make payments.")
            return
        }
        
        activityIndicator.startAnimating()
        
        let productIdentifier: Set<String> = ["com.adambinsz.Steps.Upgrade_Test"]
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifier)
        productRequest.delegate = self
        productRequest.start()
    }
    
    // MARK: - SKProductsRequestDelegate methods
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        upgradeProduct = response.products.first
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print(error)
    }
    
    
}


//
//  OnboardingViewController.swift
//  Steps
//
//  Created by Adam Binsz on 11/9/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit
import HealthKit
import BRYXGradientView
import Crashlytics

class PermissionViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    static func loadFromStoryboard() -> PermissionViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PermissionViewController") as! PermissionViewController
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .CurrentContext

        gradientView.topColor = UIColor(red: 29.0/255.0, green: 97.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        gradientView.bottomColor = UIColor(red: 25.0/255.0, green: 213.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        
        descriptionLabel.text = "Steps needs permission to read step counts from your iPhone."
    }
    
    @IBAction func confirmButtonPressed(sender: UIButton) {
        let types: Set<HKQuantityType> = [HKQuantityType.stepCount, HKQuantityType.distanceWalkingRunning]
        HKHealthStore().requestAuthorizationToShareTypes(nil, readTypes: types) { authorized, error in
            if let error = error {
                Answers.logErrorWithName("Permission Request Error", error: error)
            }
            self.imageView.backgroundColor = UIColor.greenColor()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

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
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
    }
    
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    fileprivate init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .currentContext

        gradientView.topColor = UIColor.blueGradientTopColor
        gradientView.bottomColor = UIColor.blueGradientBottomColor
        
        descriptionLabel.text = "Steps needs permission to read step counts from your iPhone."
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let types: Set<HKQuantityType> = [HKQuantityType.stepCount, HKQuantityType.distanceWalkingRunning]
        HKHealthStore().requestAuthorization(toShare: nil, read: types) { authorized, error in
            if let error = error {
                Answers.logErrorWithName("Permission Request Error", error: error as NSError?)
            }
            self.imageView.backgroundColor = UIColor.green
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

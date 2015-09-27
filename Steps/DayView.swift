//
//  DayView.swift
//  Steps
//
//  Created by Adam Binsz on 9/27/15.
//  Copyright © 2015 Adam Binsz. All rights reserved.
//

import UIKit

class DayView: UIView {
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var barWidthConstraint: NSLayoutConstraint!
    
    var barScale: CGFloat = 0.0 {
        didSet {
            if barWidthConstraint != nil {
                removeConstraint(barWidthConstraint)
            }
            
            barWidthConstraint = NSLayoutConstraint(item: barView,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Width,
                multiplier: barScale,
                constant: 1.0)
        }
    }
    
    class func loadFromNib() -> DayView {
        return UINib(nibName: "DayView", bundle: nil).instantiateWithOwner(self, options: nil).first as! DayView
    }
}
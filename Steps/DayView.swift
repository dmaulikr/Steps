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
            if barScale > 1.0 { barScale = 1.0 }
            
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
            addConstraint(barWidthConstraint)
            
            self.setNeedsLayout()
            UIView.animateWithDuration(0.88, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private init() {
        super.init(frame: CGRect.zero)
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func loadFromNib() -> DayView {
        let view = UINib(nibName: "DayView", bundle: nil).instantiateWithOwner(self, options: nil).first as! DayView
        view.backgroundColor = UIColor.clearColor()
        view.barScale = 0.0
        return view
    }
}
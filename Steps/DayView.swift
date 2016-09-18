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
            barScale = min(barScale, 1.0)
            barScale = barScale.isNaN ? 0.0 : barScale
            
            if barWidthConstraint != nil {
                removeConstraint(barWidthConstraint)
            }
            
            barWidthConstraint = NSLayoutConstraint(item: barView,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: barScale,
                constant: 1.0)
            addConstraint(barWidthConstraint)
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    fileprivate init() {
        super.init(frame: CGRect.zero)
    }
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func loadFromNib() -> DayView {
        let view = UINib(nibName: "DayView", bundle: nil).instantiate(withOwner: self, options: nil).first as! DayView
        view.backgroundColor = UIColor.clear
        view.barScale = 0.0
        
        if UIScreen.main.bounds.height >= 736 {
            var font = view.dayLabel.font
            font = UIFont(name: (font?.fontName)!, size: 26) ?? font
            view.dayLabel.font = font
            view.countLabel.font = font
        }
        
        return view
    }
}

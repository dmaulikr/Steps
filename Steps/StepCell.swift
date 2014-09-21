//
//  StepCell.swift
//  Steps
//
//  Created by Adam Binsz on 8/29/14.
//  Copyright (c) 2014 Adam Binsz. All rights reserved.
//

import UIKit

class StepCell: UITableViewCell {
    
    var countLabel: UICountingLabel
    var dayLabel: UILabel
    private var barView: UIView
    // A value between 0.0 and 1.0
    private var barWidth: CGFloat = 0.0
    
    func setBarWidth(width: CGFloat, animated: Bool) {
        barWidth = width
        var f = bounds
        f.size.width *= barWidth
        f.size.width = f.size.width < 8 ? 8 : f.size.width
        if animated {
            var b = bounds
            b.size.width = 8
            barView.frame = b
            
            UIView.animateWithDuration(10.0 / 9.0, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                self.barView.frame = f
            }, completion: nil)
        } else {
            barView.frame = f
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        barView = UIView()
        barView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.10)
        countLabel = UICountingLabel()
        countLabel.text = "0"
        countLabel.formatBlock = {(floatValue: Float) -> String in
            return Int(floatValue).formattedString()
        }
        dayLabel = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        contentView.addSubview(barView)
        
        let labels = [countLabel, dayLabel]
        let yPadding: CGFloat = 16.0
        for label in labels {
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            label.textColor = UIColor.whiteColor()
            var labelFontSize: CGFloat = 24.0
            if UIScreen.mainScreen().scale > 2.0 {
                labelFontSize *= 1.2
            }
            label.font = UIFont(name: "HelveticaNeue-Light", size: labelFontSize)
            contentView.addSubview(label)
            
            contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(\(yPadding))-[label]-(\(yPadding))-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["label" : label]))
        }
        
//        countLabel.textAlignment = NSTextAlignment.Right
//        dayLabel.textAlignment = NSTextAlignment.Left
        
        let xPadding: CGFloat = 10.0
        contentView.addConstraint(NSLayoutConstraint(item: countLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: -xPadding))
        contentView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1.0, constant: xPadding))
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var f = barView.frame
        f.size.height = CGRectGetHeight(bounds)
        f.size.width = barWidth * CGRectGetWidth(bounds)
        f.size.width = f.size.width < 8 ? 8 : f.size.width
        barView.frame = f
    }

}

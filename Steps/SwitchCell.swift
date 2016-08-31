//
//  SwitchCell.swift
//  Bryx 911
//
//  Created by Adam Binsz on 6/2/16.
//  Copyright © 2016 Bryx. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let cellSwitch = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        contentView.addSubview(label)
        label.constraintWithAttribute(.CenterY, .Equal, to: contentView, priority: 999).active = true
        label.constraintWithAttribute(.Leading, .Equal, to: .LeadingMargin, of: contentView).active = true
        label.constraintWithAttribute(.Top, .Equal, to: .TopMargin, of: contentView).active = true
        label.constraintWithAttribute(.Bottom, .Equal, to: .BottomMargin, of: contentView).active = true
        label.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        
        contentView.addSubview(cellSwitch)
        cellSwitch.constraintWithAttribute(.CenterY, .Equal, to: contentView).active = true
        cellSwitch.constraintWithAttribute(.Trailing, .Equal, to: .TrailingMargin, of: contentView).active = true
        cellSwitch.constraintWithAttribute(.Top, .GreaterThanOrEqual, to: .TopMargin, of: contentView).active = true
        cellSwitch.constraintWithAttribute(.Bottom, .LessThanOrEqual, to: .BottomMargin, of: contentView).active = true
        
        label.constraintWithAttribute(.Trailing, .Equal, to: .Leading, of: cellSwitch, constant: -8).active = true
        
        cellSwitch.addTarget(self, action: #selector(SwitchCell.cellSwitchValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellSwitchValueChanged(sender: UISwitch) {
        /* no-op */
    }
    
}
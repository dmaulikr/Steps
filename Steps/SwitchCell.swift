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
        label.constraintWithAttribute(.centerY, .equal, to: contentView, priority: 999).isActive = true
        label.constraintWithAttribute(.leading, .equal, to: .leadingMargin, of: contentView).isActive = true
        label.constraintWithAttribute(.top, .equal, to: .topMargin, of: contentView).isActive = true
        label.constraintWithAttribute(.bottom, .equal, to: .bottomMargin, of: contentView).isActive = true
        label.setContentCompressionResistancePriority(1000, for: .vertical)
        
        contentView.addSubview(cellSwitch)
        cellSwitch.constraintWithAttribute(.centerY, .equal, to: contentView).isActive = true
        cellSwitch.constraintWithAttribute(.trailing, .equal, to: .trailingMargin, of: contentView).isActive = true
        cellSwitch.constraintWithAttribute(.top, .greaterThanOrEqual, to: .topMargin, of: contentView).isActive = true
        cellSwitch.constraintWithAttribute(.bottom, .lessThanOrEqual, to: .bottomMargin, of: contentView).isActive = true
        
        label.constraintWithAttribute(.trailing, .equal, to: .leading, of: cellSwitch, constant: -8).isActive = true
        
        cellSwitch.addTarget(self, action: #selector(SwitchCell.cellSwitchValueChanged(_:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellSwitchValueChanged(_ sender: UISwitch) {
        /* no-op */
    }
    
}

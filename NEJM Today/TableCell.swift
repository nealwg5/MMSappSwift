//
//  TableCell.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/7/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var extractLabel: UILabel!
    @IBOutlet var pubDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//
//  TableViewCell.swift
//  MRZ
//
//  Created by Игорь Клещёв on 12.05.15.
//  Copyright (c) 2015 Regula Forensics. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var lFieldName: UILabel!
    @IBOutlet weak var lFieldValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

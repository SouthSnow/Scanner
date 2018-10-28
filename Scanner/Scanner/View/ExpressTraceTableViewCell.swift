//
//  ExpressTraceTableViewCell.swift
//  Scanner
//
//  Created by swifter on 2018/10/14.
//  Copyright © 2018 pfl. All rights reserved.
//

import UIKit

class ExpressTraceTableViewCell: UITableViewCell {
    @IBOutlet var expressTraceDetailLabel: UILabel!
    @IBOutlet var expressTraceTimeLineLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

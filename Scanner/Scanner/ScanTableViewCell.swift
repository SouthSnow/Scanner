//
//  ScanTableViewCell.swift
//  Scanner
//
//  Created by pfl on 15/6/5.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

class ScanTableViewCell: UITableViewCell {

    var scanImageView: UIImageView!
    
    var scanDetailLabel: UILabel!
    
    var scanDateLabel:UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

    func setupUI()
    {
        scanImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        
        scanDetailLabel = UILabel(frame: CGRect(x: scanImageView.frame.maxX+10, y: scanImageView.frame.minY, width: UIScreen.main.bounds.width - scanImageView.frame.maxX-10, height: 30))
        scanDetailLabel.textColor = UIColor.brown
        scanDetailLabel.font = UIFont.boldSystemFont(ofSize: 16)
        scanDetailLabel.textAlignment = .left
        
         scanDateLabel = UILabel(frame: CGRect(x: scanDetailLabel.frame.minX, y: scanDetailLabel.frame.maxY, width: scanDetailLabel.frame.width, height: 20))
        
        scanDateLabel.textColor = scanDetailLabel.textColor
        scanDateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        scanDateLabel.textAlignment = .left
        
        self.contentView.addSubview(scanImageView)
        self.contentView.addSubview(scanDetailLabel)
        self.contentView.addSubview(scanDateLabel)
    }
    
   

}






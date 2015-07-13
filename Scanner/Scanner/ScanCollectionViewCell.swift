//
//  ScanCollectionViewCell.swift
//  Scanner
//
//  Created by pangfuli on 15/6/6.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

class ScanCollectionViewCell: UICollectionViewCell {
    
    var scanImageView: UIImageView!
    
    var scanDetailLabel: UILabel!
    
    var scanDateLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI()
    {
        scanImageView = UIImageView(frame: CGRectMake(0, 10, 40, 40))
        
        scanDetailLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(scanImageView.frame)+10, CGRectGetMinY(scanImageView.frame), UIScreen.mainScreen().bounds.width - CGRectGetMaxX(scanImageView.frame)-10, 30))
        scanDetailLabel.textColor = UIColor.brownColor()
        scanDetailLabel.font = UIFont.boldSystemFontOfSize(16)
        scanDetailLabel.textAlignment = .Left
        
        scanDateLabel = UILabel(frame: CGRectMake(CGRectGetMinX(scanDetailLabel.frame), CGRectGetMaxY(scanDetailLabel.frame), CGRectGetWidth(scanDetailLabel.frame), 20))
        
        scanDateLabel.textColor = scanDetailLabel.textColor
        scanDateLabel.font = UIFont.boldSystemFontOfSize(12)
        scanDateLabel.textAlignment = .Left
        
        self.contentView.addSubview(scanImageView)
        self.contentView.addSubview(scanDetailLabel)
        self.contentView.addSubview(scanDateLabel)
    }

}

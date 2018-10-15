//
//  ScanDetailViewController.swift
//  Scanner
//
//  Created by swifter on 2018/10/16.
//  Copyright © 2018 pfl. All rights reserved.
//

import UIKit

class ScanDetailViewController: UIViewController, PFLAlertable {
    var content: String?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫描结果"
        self.contentLabel.text = content
    }
    @IBAction func copyAction(_ sender: Any) {
        guard let text = self.contentLabel.text else {
            return
        }
        UIPasteboard.general.string = text;
        self.showMsg("内容已复制")
    }
    

}

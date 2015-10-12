//
//  WebViewController.swift
//  Scanner
//
//  Created by pfl on 15/5/13.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       let webView = UIWebView(frame: self.view.bounds)
        view.addSubview(webView)
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

  

}

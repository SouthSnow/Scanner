//
//  HomeViewController.swift
//  Scanner
//
//  Created by swifter on 2018/10/28.
//  Copyright © 2018 pfl. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, PFLAlertable {

    @IBOutlet var queryBtn: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var scanBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAppreance()
    }

    @IBAction func doneAction(_ sender: Any) {
       
        guard let text = self.textField.text, text.length > 0 else {
            let expressVc = ExpressViewController(expressno: self.textField.text)
            self.navigationController?.pushViewController(expressVc, animated: true)
            return
        }
        
        self.queryExpress()
    }
    
    @IBAction func scanAction(_ sender: Any) {
        self.navigationController?.pushViewController(ScanViewController(), animated: true)
    }
    
    private func setupAppreance() {
        self.textField.superview!.layer.borderWidth = 0.5
        self.textField.superview!.layer.masksToBounds = true
        self.textField.superview!.layer.cornerRadius = 6
        self.textField.superview!.layer.borderColor = UIColor.green.cgColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension HomeViewController {
    private func queryExpress() {
        self.view.endEditing(true)
        guard let _ = self.textField.text else {
            return
        }
        queryBtn.isEnabled = false
        let url = URL(string: BaseURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var LogisticCode = "1072766311818"
        
        if let expressNo = self.textField.text, expressNo.pureNumberString {
            LogisticCode = expressNo
        }
        
        let requestData = ["LogisticCode":LogisticCode].toJSONString//"{" + "\"LogisticCode\":" + "\"" + LogisticCode + "\"," + "\"ShipperCode\":" + "\"" + ShipperCode + "\"" + "}"
        let RequestData = String(utf8String: requestData.cString(using: .utf8)!) ?? ""
        var DataSign = (requestData + appKey).md5
        DataSign = DataSign.toBase64()
        DataSign = DataSign.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        var parameters = [String:String]()
        parameters["RequestData"] = RequestData.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        parameters["EBusinessID"] = EBusinessID
        parameters["RequestType"] = orderIdentifyApi
        parameters["DataSign"] = DataSign
        parameters["DataType"] = "2"
        var body = ""
        parameters.forEach { (key, value) in
            body += (key.appending("=").appending(value).appending("&"))
        }
        body.remove(at: body.index(body.endIndex, offsetBy: -1))
        let data = body.data(using: .utf8)
        request.httpBody = data
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        let activity = UIActivityIndicatorView(style: .gray)
        activity.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URLSession.shared.dataTask(with: request) { (data, respose, error) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.queryBtn.isEnabled = true
                do {
                    activity.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    guard let data = data, let obj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else {return}
                    print("obj: ", obj)
                    
                    if let success = obj["Success"] as? Bool, success {
                        guard let traces: Array<[String:String]> = obj["Shippers"] as? Array else {return}
                        let expressCompany = traces.map({ dic -> ExpressCompany in
                            return ExpressCompany(dictionary:dic)
                        })
                        if expressCompany.count > 0 {
                            self.queryExpress(LogisticCode: LogisticCode, ShipperCode: expressCompany.first!.ShipperCode, ShipperName: expressCompany.first!.ShipperName)
                        }
                    }
                    else {
                        
                    }
                    
                    if let reason = obj["Reason"] as? String {self.showMsg(reason)}
                    
                } catch let error as NSError {
                    print("error: ", error.localizedDescription)
                    activity.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
            }.resume()
    }
}

extension HomeViewController {
    
    @objc fileprivate func queryExpress(LogisticCode: String, ShipperCode: String, ShipperName: String) {
        self.view.endEditing(true)
        let url = URL(string: BaseURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let requestData = ["LogisticCode":LogisticCode,"ShipperCode":ShipperCode].toJSONString//"{" + "\"LogisticCode\":" + "\"" + LogisticCode + "\"," + "\"ShipperCode\":" + "\"" + ShipperCode + "\"" + "}"
        let RequestData = String(utf8String: requestData.cString(using: .utf8)!) ?? ""
        var DataSign = (requestData + appKey).md5
        DataSign = DataSign.toBase64()
        DataSign = DataSign.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        var parameters = [String:String]()
        parameters["RequestData"] = RequestData.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        parameters["EBusinessID"] = EBusinessID
        parameters["RequestType"] = expressTraceApi
        parameters["DataSign"] = DataSign
        parameters["DataType"] = "2"
        var body = ""
        parameters.forEach { (key, value) in
            body += (key.appending("=").appending(value).appending("&"))
        }
        body.remove(at: body.index(body.endIndex, offsetBy: -1))
        let data = body.data(using: .utf8)
        request.httpBody = data
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        let activity = UIActivityIndicatorView(style: .gray)
        activity.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URLSession.shared.dataTask(with: request) { (data, respose, error) in
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hide(for: self.view, animated: true)
                do {
                    activity.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    guard let data = data, let obj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else {return}
                    print("obj: ", obj)
                    
                    if let success = obj["Success"] as? Bool, success {
                        guard let traces: Array<[String:String]> = obj["Traces"] as? Array else {return}
                        let expressTraces = traces.map({ dic -> ExpressTrace in
                            return ExpressTrace(dictionary:dic)
                        })
                        let expressTracesVc = ExpressTracesTableViewController()
                        expressTracesVc.expressTraces = expressTraces
                        expressTracesVc.title = ShipperName
                        self.navigationController?.pushViewController(expressTracesVc, animated: true)
                    }
                    else {
                        
                    }
                    
                    if let reason = obj["Reason"] as? String {self.showMsg(reason)}
                    
                } catch let error as NSError {
                    print("error: ", error.localizedDescription)
                    activity.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
            }.resume()
    }
}


extension HomeViewController: UITextFieldDelegate {
    
}

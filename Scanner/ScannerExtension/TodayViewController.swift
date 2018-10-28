//
//  TodayViewController.swift
//  ScannerExtension
//
//  Created by swifter on 2018/10/28.
//  Copyright © 2018 pfl. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var queryBtn: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var scanBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    public var expressTraces: Array<ExpressTrace>!
    let reuseIdentifier = "reuseIdentifier"
    
    @IBOutlet var activityView: UIActivityIndicatorView!
    override func viewDidLoad() {
        self.activityView.stopAnimating()
        super.viewDidLoad()
        self.setupAppreance()
        preferredContentSize = CGSize(width: 0, height: 200)
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let text = UIPasteboard.general.string, text.count > 0, text.pureNumberString else {
            return
        }
        if self.presentedViewController != nil {
            return
        }
        self.textField.text = UIPasteboard.general.string
        self.queryExpress()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.tableView.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height:max(500, maxSize.height))
            self.tableView.reloadData()
        }
        else {
            preferredContentSize = CGSize(width: 0, height: 400)
        }
    }
    
    @IBAction func queryAction(_ sender: Any) {
        guard let text = self.textField.text, text.count > 0 else {
            return
        }
        self.queryExpress()
    }
    
    @IBAction func scanAction(_ sender: Any) {
        self.extensionContext?.open(URL(string: "iScanner://")!, completionHandler: nil)
    }
    
    private func setupAppreance() {
        self.textField.superview!.layer.borderWidth = 0.5
        self.textField.superview!.layer.masksToBounds = true
        self.textField.superview!.layer.cornerRadius = 6
        self.textField.superview!.layer.borderColor = UIColor.green.cgColor
        self.tableView.register(UINib.init(nibName: "ExpressTraceTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}


extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.expressTraces == nil {
            return 0
        }
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
        preferredContentSize = CGSize(width: 0, height: (expressTraces.count+1)*80)
        return expressTraces.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExpressTraceTableViewCell
        let expressTrace = expressTraces[indexPath.section]
        cell.expressTraceDetailLabel.text = expressTrace.AcceptStation
        cell.expressTraceTimeLineLabel.text = expressTrace.AcceptTime
        cell.expressTraceDetailLabel.font = UIFont.systemFont(ofSize: 12)
        cell.expressTraceDetailLabel.font = UIFont.systemFont(ofSize: 12)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    @objc private func shareAction(_ sender: UIBarButtonItem) {
        guard let expressTraces = self.expressTraces, expressTraces.count > 0 else { return }
        let expressTrace = expressTraces[tableView.indexPathForSelectedRow?.section ?? 0]
        let state = expressTrace.AcceptTime + " 快递已到达 " + expressTrace.AcceptStation
        let items: [Any] = [state]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities:nil)
        self.present(activityVC, animated: true, completion: nil)
    }

}

extension TodayViewController {
    private func queryExpress() {
        self.view.endEditing(true)
        guard let text = self.textField.text,text.count > 0 else {
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
        let activity = self.activityView
        activity?.startAnimating()
//        MBProgressHUD.showAdded(to: self.view, animated: true)
        URLSession.shared.dataTask(with: request) { (data, respose, error) in
            DispatchQueue.main.async(execute: {
//                MBProgressHUD.hide(for: self.view, animated: true)
                self.queryBtn.isEnabled = true
                do {
                    activity!.stopAnimating()
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
                    
//                    if let reason = obj["Reason"] as? String {self.showMsg(reason)}
                    
                } catch let error as NSError {
                    print("error: ", error.localizedDescription)
                    activity?.stopAnimating()
                }
            })
            }.resume()
    }
}

extension TodayViewController {
    
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
        let activity = self.activityView
        activity?.startAnimating()
//        MBProgressHUD.showAdded(to: self.view, animated: true)
        URLSession.shared.dataTask(with: request) { (data, respose, error) in
            DispatchQueue.main.async(execute: {
//                MBProgressHUD.hide(for: self.view, animated: true)
                do {
                    activity?.stopAnimating()
                    guard let data = data, let obj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else {return}
                    print("obj: ", obj)
                    
                    if let success = obj["Success"] as? Bool, success {
                        guard let traces: Array<[String:String]> = obj["Traces"] as? Array else {return}
                        let expressTraces = traces.map({ dic -> ExpressTrace in
                            return ExpressTrace(dictionary:dic)
                        })
                        self.expressTraces = expressTraces
                        self.tableView.reloadData()
                    }
                    else {
                        
                    }
                    
//                    if let reason = obj["Reason"] as? String {self.showMsg(reason)}
                    
                } catch let error as NSError {
                    print("error: ", error.localizedDescription)
                    activity?.stopAnimating()
                }
            })
            }.resume()
    }
}

extension TodayViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.expressTraces = nil
        self.tableView.reloadData()
        self.textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count > 0 {
            return true
        }
        let detailVc = DetailViewController()
        detailVc.preferredContentSizeHandler = { size in
            self.preferredContentSize = size
            self.tableView.reloadData()
        }
        detailVc.openScannerHandler = {
            self.scanAction(self.scanBtn)
        }
        self.present(detailVc, animated: false, completion: nil)
        return true
    }
    
}



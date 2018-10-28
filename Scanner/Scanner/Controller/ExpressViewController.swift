//
//  ExpressViewController.swift
//  Scanner
//
//  Created by fuli pang on 2017/1/9.
//  Copyright © 2017年 pfl. All rights reserved.
//

import UIKit
import StoreKit



/// 快递查询
class ExpressViewController: UIViewController, PFLAlertable {

    let RequestType = expressTraceApi
    let DataType = "2"
    var selectedExpress: ExpressModel?
    
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        tableView.y = self.headView.bottom
        tableView.height = self.view.height - tableView.y
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    lazy var headView: UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: self.navigationController?.navigationBar.frame.maxY ?? 64, width: UIScreen.main.bounds.width, height: 80))
        vi.backgroundColor = .white
        return vi
    }()
    
    lazy var expressLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.width = 75
        label.height = 30
        label.centerY = 40//self.expressImageView.bottom
        label.centerX = label.width/2 + 10
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "EMS"
        return label
    }()

    lazy var expressImageView: UIImageView = {
        var imageView = UIImageView(frame: .zero)
        imageView.x = 20
        imageView.width = 40
        imageView.height = 40
        return imageView
    }()
    
    lazy var expressNoTextField: UITextField = {
        var label = UITextField(frame: .zero)
        label.keyboardType = UIKeyboardType.numberPad
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.borderStyle = .none
        label.backgroundColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.height = 30
        label.clearButtonMode = .whileEditing
        label.x = self.expressLabel.right
        label.width = UIScreen.main.bounds.width - label.x - 10 - 50 - 10
        label.centerY = 40
        return label
    }()
    
    lazy var queryBtn: UIButton = {
        var btn = UIButton(type: .custom)
        btn.size = CGSize(width: 50, height: 30)
        btn.setTitleColor(.blue, for: .normal)
        btn.setTitle("查询", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.centerY = self.expressNoTextField.centerY
        btn.right = self.view.width - 10
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blue.cgColor
        btn.addTarget(nil, action: #selector(queryExpress), for: .touchUpInside)
        return btn
    }()
    
    init(expressno: String?) {
        super.init(nibName: nil, bundle: nil)
        self.title = "查询快递"
        self.expressNoTextField.text = expressno
        if let expressno = expressno, !expressno.pureNumberString  {
            self.expressNoTextField.text = nil
            self.expressNoTextField.placeholder = "输入快递订单号"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.headView)
        self.headView.addSubview(self.expressImageView)
        self.headView.addSubview(self.expressLabel)
        self.headView.addSubview(self.expressNoTextField)
        self.headView.addSubview(self.queryBtn)
        self.view.addSubview(self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }

    
    lazy fileprivate var  expressDataSource: [ExpressModel] = {
        var dataSource = [ExpressModel]()
        guard
            let dic = self.fetchExpressPath(),
            let items = dic["items"] as? [[String:String]] else {return dataSource}
       let dataSource_ = items.map{
            return ExpressModel(exname: $0["exname"], img: $0["img"], com: $0["com"], exid: $0["exid"], phone: $0["phone"])
        }
        dataSource.append(contentsOf: dataSource_)
        return dataSource
    }()
    
    fileprivate func fetchExpressPath() -> NSDictionary? {
        guard
            let path = Bundle.main.path(forResource: "express_list", ofType: "plist"),
            let data = NSDictionary(contentsOfFile: path) else {return nil}
        return data
    }
    
    @objc fileprivate func queryExpress(btn: UIButton) {
        self.view.endEditing(true)
        guard let _ = self.expressNoTextField.text else {
            return
        }
        btn.isEnabled = false
        let url = URL(string: BaseURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var ShipperCode = "ems"
        if let selectedExpress = self.selectedExpress {
            ShipperCode = selectedExpress.com ?? "ems"
        }
        var LogisticCode = "1072766311818"
        
        if let expressNo = self.expressNoTextField.text, expressNo.pureNumberString {
            LogisticCode = expressNo
        }
        
        let requestData = ["LogisticCode":LogisticCode,"ShipperCode":ShipperCode].toJSONString//"{" + "\"LogisticCode\":" + "\"" + LogisticCode + "\"," + "\"ShipperCode\":" + "\"" + ShipperCode + "\"" + "}"
        let RequestData = String(utf8String: requestData.cString(using: .utf8)!) ?? ""
        var DataSign = (requestData + appKey).md5
        DataSign = DataSign.toBase64()
        DataSign = DataSign.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        var parameters = [String:String]()
        parameters["RequestData"] = RequestData.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        parameters["EBusinessID"] = EBusinessID
        parameters["RequestType"] = RequestType
        parameters["DataSign"] = DataSign
        parameters["DataType"] = DataType
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
                btn.isEnabled = true
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
                        expressTracesVc.title = self.expressLabel.text
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

extension ExpressViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.expressDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let express = self.expressDataSource[indexPath.section]
        cell.textLabel?.text = express.exname
        cell.imageView?.image = UIImage(named: express.img ?? "")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let express = self.expressDataSource[indexPath.section]
        self.selectedExpress = express
        self.expressLabel.text = express.exname
        self.expressImageView.image = UIImage(named: express.img ?? "")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
}






















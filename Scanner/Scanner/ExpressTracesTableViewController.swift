//
//  ExpressTracesTableViewController.swift
//  Scanner
//
//  Created by swifter on 2018/10/14.
//  Copyright © 2018 pfl. All rights reserved.
//

import UIKit

struct ExpressTrace {
    let AcceptStation: String
    let AcceptTime: String
    init(dictionary:[String: String]) {
        AcceptTime = dictionary["AcceptTime"] ?? ""
        AcceptStation = dictionary["AcceptStation"] ?? ""
    }
}

class ExpressTracesTableViewController: UITableViewController {
    let reuseIdentifier = "reuseIdentifier"

    public var expressTraces: Array<ExpressTrace>!
    public var aTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = aTitle ?? title
         self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "share"), style: .done, target: self, action: #selector(shareAction(_:)))
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        self.tableView.register(UINib.init(nibName: "ExpressTraceTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return expressTraces.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ExpressTraceTableViewCell
        let expressTrace = expressTraces[indexPath.section]
        cell.expressTraceDetailLabel.text = expressTrace.AcceptStation
        cell.expressTraceTimeLineLabel.text = expressTrace.AcceptTime
        return cell
    }
 

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5.01
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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

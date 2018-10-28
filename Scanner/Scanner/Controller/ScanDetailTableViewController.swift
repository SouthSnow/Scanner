//
//  ScanDetailTableViewController.swift
//  Scanner
//
//  Created by pfl on 15/6/3.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit.SKStoreProductViewController

class ScanDetailTableViewController: UITableViewController {

    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var managedObjectContext: NSManagedObjectContext?
     var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var stack: PersistentStack!

    
    var persistentStoreCoordinatorChangesObserver:NotificationCenter? {
        didSet {
            
            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: self.stack.managedContext.persistentStoreCoordinator)
            oldValue?.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: self.stack.managedContext.persistentStoreCoordinator)
            
            persistentStoreCoordinatorChangesObserver?.addObserver(self, selector: #selector(ScanDetailTableViewController.persistentStoreCoordinatorStoresWillChange(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: self.stack.managedContext.persistentStoreCoordinator)
            persistentStoreCoordinatorChangesObserver?.addObserver(self, selector: #selector(ScanDetailTableViewController.persistentStoreCoordinatorStoresDidChange(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: self.stack.managedContext.persistentStoreCoordinator)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫描记录"
        tableView.register(ScanTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.rowHeight = 60
        stack = appDelegate.stack
        stack.updateContextWithUbiquitousContentUpdates = true
        persistentStoreCoordinatorChangesObserver = NotificationCenter.default
        fetchResultsController = stack.fetchedResultsController
        fetchResultsController?.delegate = self
        managedObjectContext = stack.managedContext
        var error: NSError?
        do {
            try fetchResultsController?.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        tableView.reloadData()
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func persistentStoreCoordinatorStoresWillChange(_ notification: Notification) {
        
        let error: NSErrorPointer? = nil
        if self.stack.managedContext.hasChanges {
            do {
                try self.stack.managedContext.save()
            } catch let error1 as NSError {
                error??.pointee = error1
                
            }
        }
        
    }
    
    @objc func persistentStoreCoordinatorStoresDidChange(_ notification: Notification) {
        
        var error: NSError?
        do {
            try fetchResultsController?.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
    }
 

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
   
        if let sections = fetchResultsController?.sections
        {
            return  sections.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        
        if let sections = fetchResultsController?.sections
        {
            let sectionInfo: AnyObject =  sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") as! ScanTableViewCell
        let scanItem = fetchResultsController?.object(at: indexPath) as! ScanItem
        
        cell.scanImageView.image = UIImage(named:"scan")
        cell.scanDetailLabel.text = scanItem.scanDetail
        cell.scanDateLabel.text = scanItem.scanDate

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let scanItem = fetchResultsController?.object(at: indexPath) as! ScanItem
        let todo = {
            let detailVc = ScanDetailViewController()
            detailVc.content = scanItem.scanDetail
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
        
        if scanItem.scanDetail.lowercased().hasPrefix("http") || scanItem.scanDetail.lowercased().hasPrefix("www") {
            guard let url = URL(string:scanItem.scanDetail) else {todo();return}
            if #available(iOS 9.0, *) {
                guard let _ = url.scheme else {todo();return}
                let sfVc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                self.present(sfVc, animated: true, completion: nil)
            } else {
//                if url.absoluteString.contains("://itunes.apple.com") {
//                    let sksVc = SKStoreProductViewController(nibName: nil, bundle: nil)
//                    sksVc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier:"987975567"], completionBlock: nil)
//                    sksVc.delegate = self
//                    self.present(sksVc, animated: true, completion: nil)
//                    return
//                }
//                else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
                else {
                    todo()
                }
//                }
            }
        }
        else if let detail = scanItem.scanDetail, detail.length > 0, detail.pureNumberString {
            let scanDetail = ExpressViewController(expressno: scanItem.scanDetail)
            self.navigationController?.pushViewController(scanDetail, animated: true)
        }
        else {
            let detailVc = ScanDetailViewController()
            detailVc.content = scanItem.scanDetail
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
        
        todo:do {
            let detailVc = ScanDetailViewController()
            detailVc.content = scanItem.scanDetail
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
        
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let item = fetchResultsController?.object(at: indexPath) as! ScanItem
        
        self.managedObjectContext!.delete(item)
        do {
            try self.managedObjectContext?.save()
        } catch _ {
        }
    }
   
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    deinit
    {
        fetchResultsController?.delegate = nil
    }
    
    

}
        // MARK: NSFetchResultsControllerDelegate
extension ScanDetailTableViewController: NSFetchedResultsControllerDelegate
{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type
        {
            case NSFetchedResultsChangeType.delete:
                tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.automatic)
            
            case NSFetchedResultsChangeType.insert:
                tableView.insertRows(at: [newIndexPath!], with: UITableView.RowAnimation.automatic)
            default: break
        }
    }
}


extension ScanDetailTableViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}









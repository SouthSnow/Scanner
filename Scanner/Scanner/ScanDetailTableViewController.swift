//
//  ScanDetailTableViewController.swift
//  Scanner
//
//  Created by pfl on 15/6/3.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

class ScanDetailTableViewController: UITableViewController {

    var fetchResultsController: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
     var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var stack: PersistentStack!

    
    var persistentStoreCoordinatorChangesObserver:NSNotificationCenter? {
        didSet {
            
            oldValue?.removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.stack.managedContext.persistentStoreCoordinator)
            oldValue?.removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.stack.managedContext.persistentStoreCoordinator)
            
            persistentStoreCoordinatorChangesObserver?.addObserver(self, selector: "persistentStoreCoordinatorStoresWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.stack.managedContext.persistentStoreCoordinator)
            persistentStoreCoordinatorChangesObserver?.addObserver(self, selector: "persistentStoreCoordinatorStoresDidChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.stack.managedContext.persistentStoreCoordinator)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(ScanTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.rowHeight = 60
        stack = appDelegate.stack
        stack.updateContextWithUbiquitousContentUpdates = true
        persistentStoreCoordinatorChangesObserver = NSNotificationCenter.defaultCenter()
        fetchResultsController = stack.fetchedResultsController
        fetchResultsController?.delegate = self
        managedObjectContext = stack.managedContext
        var error: NSError?
        fetchResultsController?.performFetch(&error)
        tableView.reloadData()
    }

    
    
    func persistentStoreCoordinatorStoresWillChange(notification: NSNotification) {
        
        var error: NSErrorPointer = nil
        if self.stack.managedContext.hasChanges {
            if !self.stack.managedContext.save(error) {
                
            }
        }
        
    }
    
    func persistentStoreCoordinatorStoresDidChange(notification: NSNotification) {
        
        var error: NSError?
        fetchResultsController?.performFetch(&error)
    }
 

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
   
        if let sections = fetchResultsController?.sections
        {
            return  fetchResultsController!.sections!.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        
        if let sections = fetchResultsController?.sections
        {
            let sectionInfo: AnyObject =  sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! ScanTableViewCell
        var scanItem = fetchResultsController?.objectAtIndexPath(indexPath) as! ScanItem
        
        cell.scanImageView.image = UIImage(named:"scan")
        cell.scanDetailLabel.text = scanItem.scanDetail
        cell.scanDateLabel.text = scanItem.scanDate

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var scanItem = fetchResultsController?.objectAtIndexPath(indexPath) as! ScanItem
        if scanItem.scanDetail.hasPrefix("http") || scanItem.scanDetail.hasPrefix("www")
        {
            UIApplication.sharedApplication().openURL(NSURL(string:scanItem.scanDetail)!)
        }
    }

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = fetchResultsController?.objectAtIndexPath(indexPath) as! ScanItem
        
        self.managedObjectContext!.deleteObject(item)
        self.managedObjectContext?.save(nil)
    }
   
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type
        {
            case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            case NSFetchedResultsChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            default: break
        }
        
        
    }
}












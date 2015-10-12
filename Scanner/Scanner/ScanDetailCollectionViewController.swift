//
//  ScanDetailCollectionViewController.swift
//  Scanner
//
//  Created by pfl on 15/6/5.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class ScanDetailCollectionViewController: UICollectionViewController, MKMasonryViewLayoutDelegate, UIGestureRecognizerDelegate {

    var fetchResultsController: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
    var stack: PersistentStack!

    
    var cellCount:Int = 10

    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stack = appDelegate.stack

        self.stack.updateContextWithUbiquitousContentUpdates = true
  
        managedObjectContext = stack.managedContext
        fetchResultsController = stack.fetchedResultsController
        fetchResultsController?.delegate = self
        
        self.collectionView!.registerClass(ScanCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      
        self.collectionView?.backgroundColor = UIColor.whiteColor()
       
        var error: NSError?
        do {
            try fetchResultsController?.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
       
//        var longGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
//        self.collectionView?.addGestureRecognizer(longGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        self.collectionView?.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: stack.managedContext.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: stack.managedContext.persistentStoreCoordinator)
    }
    
    func registerNotification()
    {
      
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreCoordinatorStoresWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: stack.managedContext.persistentStoreCoordinator)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreCoordinatorStoresDidChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: stack.managedContext.persistentStoreCoordinator)
        
    }
    
    func persistentStoreCoordinatorStoresWillChange(notification: NSNotification)
    {
        if stack.managedContext.hasChanges
        {
            let error: NSErrorPointer = nil
            do {
                try stack.managedContext.save()
            } catch let error1 as NSError {
                error.memory = error1
                print("error saving \(error)")
            }
        }
    }
    
    func persistentStoreCoordinatorStoresDidChange(notification: NSNotification)
    {
        do {
            try fetchResultsController?.performFetch()
        } catch _ {
        }
        
        print("persistentStoreCoordinatorStoresDidChange")
        
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
     
        
        if let sections = fetchResultsController?.sections
        {
            
            return  fetchResultsController!.sections!.count
            
        }
        return 0
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        if let sections = fetchResultsController?.sections
        {
            let sectionInfo: AnyObject =  sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ScanCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ScanCollectionViewCell
       
        
        let scanItem = fetchResultsController?.objectAtIndexPath(indexPath) as! ScanItem
        
        cell.scanImageView.image = UIImage(named:"scan")
        cell.scanDetailLabel.text = scanItem.scanDetail
        cell.scanDateLabel.text = scanItem.scanDate
        
        return cell 
    }

    func collectionView(collectionView: UICollectionView, layout: ScanViewLayout, heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60
    }
    
 
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let scanItem = fetchResultsController?.objectAtIndexPath(indexPath) as! ScanItem
        if scanItem.scanDetail.hasPrefix("www") || scanItem.scanDetail.hasPrefix("http")
        {
            UIApplication.sharedApplication().openURL(NSURL(string: scanItem.scanDetail!)!)
        }
        
    }

    
    // MARK: UIGestrueRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func handlePanGesture(panGesture: UIPanGestureRecognizer)
    {
        
        let dragLayout = self.collectionView?.collectionViewLayout as! ScanViewLayout
        if  self.collectionView == nil
        {
            return
        }
        let point = panGesture.translationInView(self.collectionView!)
        let locationPoint = panGesture.locationInView(self.collectionView!)
        let indexpath: NSIndexPath? = self.collectionView!.indexPathForItemAtPoint(locationPoint)
        if indexpath == nil
        {
            return
        }

    
        if point.x < 0
        {
           

            if panGesture.state == UIGestureRecognizerState.Ended
            {
                
                let item: ScanItem = self.fetchResultsController?.objectAtIndexPath(indexpath!) as! ScanItem
                self.managedObjectContext!.deleteObject(item)
                do {
                    try self.managedObjectContext?.save()
                } catch _ {
                }
                
            }
            

        }
        
        
    }
    
    
    func handleLongPress(longPress:UILongPressGestureRecognizer)
    {
        let dragLayout = self.collectionView?.collectionViewLayout as! ScanViewLayout
        let point = longPress.locationInView(self.collectionView)
        let indexpath = self.collectionView?.indexPathForItemAtPoint(point)
        if indexpath == nil
        {
            return
        }
        var cell = self.collectionView?.cellForItemAtIndexPath(indexpath!) as! ScanCollectionViewCell
        
        switch longPress.state
        {
        case .Began:
            dragLayout.startDraggingIndexPath(indexPath: indexpath!, fromPoint: point)
        case .Ended:
            fallthrough
        case .Cancelled:
            dragLayout.stopDrag()
        case .Changed:
            dragLayout.updateDragLocation(point)
        default: break
            
        }
        
        
    }
    
    deinit
    {
        fetchResultsController?.delegate = nil
    }
    

}


extension ScanDetailCollectionViewController: NSFetchedResultsControllerDelegate
{
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?){

        if type == NSFetchedResultsChangeType.Delete
        {
            collectionView?.performBatchUpdates({[weak collectionView] () -> Void in
                if let strongSelf = collectionView
                {
                    strongSelf.deleteItemsAtIndexPaths([indexPath!])
                }
            }, completion: nil)
        }
        if type == NSFetchedResultsChangeType.Insert
        {
            collectionView?.performBatchUpdates({ () -> Void in
                
                self.collectionView?.insertItemsAtIndexPaths([indexPath!])
                
            }, completion: nil)
        }
       
        
        
        
    }
    
    
   
    
}












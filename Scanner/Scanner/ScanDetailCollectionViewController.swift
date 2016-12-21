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

    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var managedObjectContext: NSManagedObjectContext?
    var stack: PersistentStack!

    
    var cellCount:Int = 10

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stack = appDelegate.stack

        self.stack.updateContextWithUbiquitousContentUpdates = true
  
        managedObjectContext = stack.managedContext
        fetchResultsController = stack.fetchedResultsController
        fetchResultsController?.delegate = self
        
        self.collectionView!.register(ScanCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      
        self.collectionView?.backgroundColor = UIColor.white
       
        var error: NSError?
        do {
            try fetchResultsController?.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
       
//        var longGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
//        self.collectionView?.addGestureRecognizer(longGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ScanDetailCollectionViewController.handlePanGesture(_:)))
        self.collectionView?.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: stack.managedContext.persistentStoreCoordinator)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: stack.managedContext.persistentStoreCoordinator)
    }
    
    func registerNotification()
    {
      
        NotificationCenter.default.addObserver(self, selector: #selector(ScanDetailCollectionViewController.persistentStoreCoordinatorStoresWillChange(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: stack.managedContext.persistentStoreCoordinator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScanDetailCollectionViewController.persistentStoreCoordinatorStoresDidChange(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: stack.managedContext.persistentStoreCoordinator)
        
    }
    
    func persistentStoreCoordinatorStoresWillChange(_ notification: Notification)
    {
        if stack.managedContext.hasChanges
        {
            let error: NSErrorPointer? = nil
            do {
                try stack.managedContext.save()
            } catch let error1 as NSError {
                error??.pointee = error1
                print("error saving \(error)")
            }
        }
    }
    
    func persistentStoreCoordinatorStoresDidChange(_ notification: Notification)
    {
        do {
            try fetchResultsController?.performFetch()
        } catch _ {
        }
        
        print("persistentStoreCoordinatorStoresDidChange")
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
     
        
        if let sections = fetchResultsController?.sections
        {
            
            return  fetchResultsController!.sections!.count
            
        }
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        if let sections = fetchResultsController?.sections
        {
            let sectionInfo: AnyObject =  sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ScanCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ScanCollectionViewCell
       
        
        let scanItem = fetchResultsController?.object(at: indexPath) as! ScanItem
        
        cell.scanImageView.image = UIImage(named:"scan")
        cell.scanDetailLabel.text = scanItem.scanDetail
        cell.scanDateLabel.text = scanItem.scanDate
        
        return cell 
    }

    func collectionView(_ collectionView: UICollectionView, layout: ScanViewLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let scanItem = fetchResultsController?.object(at: indexPath) as! ScanItem
        if scanItem.scanDetail.hasPrefix("www") || scanItem.scanDetail.hasPrefix("http")
        {
            UIApplication.shared.openURL(URL(string: scanItem.scanDetail!)!)
        }
        
    }

    
    // MARK: UIGestrueRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer)
    {
        
        let dragLayout = self.collectionView?.collectionViewLayout as! ScanViewLayout
        if  self.collectionView == nil
        {
            return
        }
        let point = panGesture.translation(in: self.collectionView!)
        let locationPoint = panGesture.location(in: self.collectionView!)
        let indexpath: IndexPath? = self.collectionView!.indexPathForItem(at: locationPoint)
        if indexpath == nil
        {
            return
        }

    
        if point.x < 0
        {
           

            if panGesture.state == UIGestureRecognizerState.ended
            {
                
                let item: ScanItem = self.fetchResultsController?.object(at: indexpath!) as! ScanItem
                self.managedObjectContext!.delete(item)
                do {
                    try self.managedObjectContext?.save()
                } catch _ {
                }
                
            }
            

        }
        
        
    }
    
    
    func handleLongPress(_ longPress:UILongPressGestureRecognizer)
    {
        let dragLayout = self.collectionView?.collectionViewLayout as! ScanViewLayout
        let point = longPress.location(in: self.collectionView)
        let indexpath = self.collectionView?.indexPathForItem(at: point)
        if indexpath == nil
        {
            return
        }
        var cell = self.collectionView?.cellForItem(at: indexpath!) as! ScanCollectionViewCell
        
        switch longPress.state
        {
        case .began:
            dragLayout.startDraggingIndexPath(indexPath: indexpath!, fromPoint: point)
        case .ended:
            fallthrough
        case .cancelled:
            dragLayout.stopDrag()
        case .changed:
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){

        if type == NSFetchedResultsChangeType.delete
        {
            collectionView?.performBatchUpdates({[weak collectionView] () -> Void in
                if let strongSelf = collectionView
                {
                    strongSelf.deleteItems(at: [indexPath!])
                }
            }, completion: nil)
        }
        if type == NSFetchedResultsChangeType.insert
        {
            collectionView?.performBatchUpdates({ () -> Void in
                
                self.collectionView?.insertItems(at: [indexPath!])
                
            }, completion: nil)
        }
       
        
        
        
    }
    
    
   
    
}












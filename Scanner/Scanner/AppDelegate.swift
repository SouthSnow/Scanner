//
//  AppDelegate.swift
//  Scanner
//
//  Created by pfl on 15/5/13.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UIAlertViewDelegate {

    var window: UIWindow?
    var persistentStack: PersistentStack?
    var store: Store?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let nav = self.window?.rootViewController as! UINavigationController
        let rootVC: ViewController = nav.topViewController as! ViewController
//        persistentStack = PersistentStack(storeURL: storeURL().0, modelURL: storeURL().1)
//        store = Store()
//        store?.managedContext = persistentStack?.managedContext
//        rootVC.managedObjectContext = persistentStack?.managedContext
//        rootVC.fetchResultsController = store?.getFetchResultsControllers()
        Fabric.with([Crashlytics()])
//        rootVC.managedObjectContext = stack.managedContext//self.managedObjectContext
//        rootVC.fetchResultsController = stack.fetchedResultsController//self.fetchResultsController
        rootVC.stack = self.stack
//        registerForiCloudNotifications()
//        registerNotifications()
        
        initCloud()
        
        return true
    }
    
    

    lazy var stack: PersistentStack = {
        let stack = PersistentStack(storeName: "db", modelName: "ScanItems", options: self.storeOptions)
        return stack;
        }()
    
    
    func storeURL()->(NSURL,NSURL)
    {
        let documentDirectory = try? NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
        
        
        // MARK: 
        let modelURL = NSBundle.mainBundle().URLForResource("ScanItems", withExtension: "momd")
        
        return (documentDirectory!.URLByAppendingPathComponent("db.sqlite"),modelURL!)
    }
    
    
    func initCloud()->Bool
    {
        let fm = NSFileManager.defaultManager()
        if fm.URLForUbiquityContainerIdentifier(nil) == nil
        {
            let alertView = UIAlertView(title: "提示", message: "iCloud不可用", delegate: self, cancelButtonTitle: "好的")
            
            return false
        }
        
        
        return true
    }
    
    
    func registerNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSavePrivateQueueContext", name: NSManagedObjectContextDidSaveNotification, object: persistentStack?.managedContext)
    }
    
    func contextDidSavePrivateQueueContext(notification: NSNotification)
    {
        persistentStack?.managedContext.performBlock({ () -> Void in
            
            persistentStack?.managedContext.mergeChangesFromContextDidSaveNotification(notification)
            
        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.saveContext()
    }

    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.pfl.CoreDatasss" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    
    lazy var cloudDirectory: NSURL = {
        
        var teamID = "iCloud."
        var bundleID = NSBundle.mainBundle().bundleIdentifier!
        var cloudRoot = "\(teamID)\(bundleID).sync"
        let url = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier("\(cloudRoot)")
        return url!
        
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ScanItems", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("db.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: self.storeOptions)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    lazy var fetchResultsController: NSFetchedResultsController = {
       
        var fetchRequset = NSFetchRequest(entityName: "ScanItem")
        fetchRequset.predicate = NSPredicate(value: true)
        fetchRequset.sortDescriptors = [NSSortDescriptor(key: "scanDate", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequset, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
    }()
    
    
    lazy var storeOptions: [NSObject : AnyObject] = {
       
        return [

            NSMigratePersistentStoresAutomaticallyOption:true,
            NSInferMappingModelAutomaticallyOption: true,
            NSPersistentStoreUbiquitousContentNameKey : "db",
            NSPersistentStoreUbiquitousPeerTokenOption: "c405d8e8a24s11e3bbec425861s862bs"]
        
    }()
    
    
    
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

    
    
    
    func registerForiCloudNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
//        notificationCenter.addObserver(self, selector: "storesWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: persistentStoreCoordinator)
//        notificationCenter.addObserver(self, selector: "storesDidChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: "persistentStoreDidImportUbiquitousContentChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: persistentStoreCoordinator)
    }
    
    func persistentStoreDidImportUbiquitousContentChanges(notification:NSNotification){
        let context = self.managedObjectContext!
        context.performBlock({
            context.mergeChangesFromContextDidSaveNotification(notification)
            
        })
    }
    
    func storesWillChange(notification:NSNotification) {
        print("Store Will change")
        let context:NSManagedObjectContext! = self.managedObjectContext
        context?.performBlock({
            var error:NSError?
            if (context.hasChanges) {
                var success: Bool
                do {
                    try context.save()
                    success = true
                } catch let error1 as NSError {
                    error = error1
                    success = false
                } catch {
                    fatalError()
                }
                
                if (!success && (error != nil)) {
                    // 执行错误处理
                    NSLog("%@",error!.localizedDescription)
                    self.showAlert()
                }
            }
            context.reset()
        })
        
    }
    
    
    
    func showAlert() {
        let message = UIAlertView(title:"iCloud 同步错误", message:"是否使用 iCloud 版本备份覆盖本地记录", delegate: self, cancelButtonTitle:"不要", otherButtonTitles:"好的")
        message.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.migrateLocalStoreToiCloudStore()
        case 1:
            self.migrateiCloudStoreToLocalStore()
        default:
            print("Do nothing")
        }
    }
    
    func storesDidChange(notification:NSNotification){
        print("Store did change")
        NSNotificationCenter.defaultCenter().postNotificationName("CoreDataDidUpdated", object: nil)
    }
    
    func migrateLocalStoreToiCloudStore() {
        print("Migrate local to icloud")
        var oldStore = persistentStoreCoordinator?.persistentStores.first
        var localStoreOptions = self.storeOptions
        localStoreOptions[NSPersistentStoreRemoveUbiquitousMetadataOption] = true
        var newStore = try? persistentStoreCoordinator?.migratePersistentStore(oldStore!, toURL: cloudDirectory, options: localStoreOptions, withType: NSSQLiteStoreType)
        
        reloadStore(newStore!)
    }
    
    func migrateiCloudStoreToLocalStore() {
        print("Migrate icloud to local")
        var oldStore = persistentStoreCoordinator?.persistentStores.first
        var localStoreOptions = self.storeOptions
        localStoreOptions[NSPersistentStoreRemoveUbiquitousMetadataOption] = true
        var newStore = try? persistentStoreCoordinator?.migratePersistentStore(oldStore!, toURL:  self.applicationDocumentsDirectory.URLByAppendingPathComponent("Diary.sqlite"), options: localStoreOptions, withType: NSSQLiteStoreType)
        
        reloadStore(newStore!)
    }
    
    func reloadStore(store: NSPersistentStore?) {
        if (store != nil) {
            do {
                try persistentStoreCoordinator?.removePersistentStore(store!)
            } catch _ {
            }
        }
        
        try? persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.applicationDocumentsDirectory.URLByAppendingPathComponent("Diary.sqlite"), options: self.storeOptions)
        
        NSNotificationCenter.defaultCenter().postNotificationName("CoreDataDidUpdated", object: nil)
    }
    


}



































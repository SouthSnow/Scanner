//
//  ScanDocument.swift
//  Scanner
//
//  Created by pfl on 15/6/10.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

class ScanDocument: UIDocument {
  
    
    var scanDetail: String?
        {
            set {
                
                let oldString = scanDetail
                self.scanDetail = newValue
                self.undoManager.setActionName("scan change")
                self.undoManager.registerUndoWithTarget(self, selector: "setScanDetail", object: oldString)
            }
            get {
                
                return self.scanDetail
            }
    }
    
    
    override func contentsForType(typeName: String) throws -> AnyObject {
        let outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        
        if let scanDetail = self.scanDetail
        {
            
        }
        else
        {
            self.scanDetail = ""
        }
        
        let data = self.scanDetail?.dataUsingEncoding(NSUTF8StringEncoding)
        if let value = data {
            return value
        }
        throw outError
        
    }
    
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        
        
        if contents.length() > 0
        {
            self.scanDetail = contents as? String
        }
    }
    
    
    
}

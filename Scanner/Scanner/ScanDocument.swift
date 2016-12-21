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
                self.undoManager.registerUndo(withTarget: self, selector: "setScanDetail", object: oldString)
            }
            get {
                
                return self.scanDetail
            }
    }
    
    
    override func contents(forType typeName: String) throws -> Any {
        let outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        
        if let scanDetail = self.scanDetail
        {
            
        }
        else
        {
            self.scanDetail = ""
        }
        
        let data = self.scanDetail?.data(using: String.Encoding.utf8)
        if let value = data {
            return value
        }
        throw outError
        
    }
    
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        
        if (contents as AnyObject).length() > 0
        {
            self.scanDetail = contents as? String
        }
    }
    
    
    
}

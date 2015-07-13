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
                
                var oldString = scanDetail
                self.scanDetail = newValue
                self.undoManager.setActionName("scan change")
                self.undoManager.registerUndoWithTarget(self, selector: "setScanDetail", object: oldString)
            }
            get {
                
                return self.scanDetail
            }
    }
    
    
    override func contentsForType(typeName: String, error outError: NSErrorPointer) -> AnyObject? {
        
        if let scanDetail = self.scanDetail
        {
            
        }
        else
        {
            self.scanDetail = ""
        }
        
        let data = self.scanDetail?.dataUsingEncoding(NSUTF8StringEncoding)
        return data
        
    }
    
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        
        
        if contents.length() > 0
        {
            self.scanDetail = contents as? String
        }
        
        return true
    }
    
    
    
}

//
//  ScanViewLayout.swift
//  Scanner
//
//  Created by pfl on 15/6/5.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit

protocol MKMasonryViewLayoutDelegate
{
    func collectionView(collectionView:UICollectionView, layout: ScanViewLayout, heightForItemAtIndexPath indexPath:NSIndexPath)->CGFloat
}

class ScanViewLayout: UICollectionViewLayout {
   
    private var lastYValueForColumn = Dictionary<Int,AnyObject>?()//NSMutableDictionary?
    private var layoutInfo = Dictionary<NSObject,AnyObject>?()
    private var indexPath: NSIndexPath?
    private var animator: UIDynamicAnimator?
    private var behavior: UIAttachmentBehavior?
    private var deleteIndexPaths: NSMutableArray?
    private var insertIndexPaths: NSMutableArray?
    
    var numberOfColumn: NSInteger!
    var interItemSpacing: CGFloat!
    var delegate: MKMasonryViewLayoutDelegate?
    var isDrag: Bool = false
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        layoutInfo = [0:0]
        lastYValueForColumn = [0:0]
        
        for indexPath in lastYValueForColumn!.keys
        {
//            lastYValueForColumn?.setObject(NSNumber(double: 0), forKey: indexPath)
//            lastYValueForColumn?.updateValue(0, forKey: indexPath)
            lastYValueForColumn![indexPath] = 0
        }
        
        
        numberOfColumn = 1
        interItemSpacing = 0
        var currentColumn: Int = 0
        let fullWidth = collectionView?.bounds.width
        var availableSpaceExcludingPadding: CGFloat = fullWidth! - interItemSpacing * (CGFloat(numberOfColumn!) + 1)
        var itemWith: CGFloat = availableSpaceExcludingPadding / CGFloat(numberOfColumn)
        
        let numSections = self.collectionView?.numberOfSections()
        
        if let numSections = numSections
        {
            for section in 0..<numSections
            {
                var numItems = self.collectionView?.numberOfItemsInSection(section)
                
                if let numItems = numItems
                {
                    for itemIndex in 0..<numItems
                    {
                        var indexPath = NSIndexPath(forItem: itemIndex, inSection: section)
                        
                        var itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                        var x = interItemSpacing + (interItemSpacing + itemWith) * CGFloat(currentColumn)
                        
                        var y: CGFloat = 0
                        
                        if let obj: AnyObject = lastYValueForColumn![currentColumn]//lastYValueForColumn!.objectForKey(NSNumber(integer: currentColumn))
                        {
                            y = CGFloat(obj as! NSNumber)
                        }
                        
                        
                        var height: CGFloat = (self.collectionView?.delegate as! MKMasonryViewLayoutDelegate).collectionView(collectionView!, layout: self, heightForItemAtIndexPath: indexPath)
                        itemAttributes.frame = CGRectMake(x, y, itemWith, height)
                        y += height
                        y += interItemSpacing
                        
//                        lastYValueForColumn?.setObject(NSNumber(double: Double(y)), forKey: NSNumber(integer: currentColumn))
//                        lastYValueForColumn?.updateValue(y, forKey: currentColumn)
                        lastYValueForColumn![currentColumn] = y
                        currentColumn++
                        if currentColumn == numberOfColumn
                        {
                            currentColumn = 0
                        }
                        
//                        layoutInfo?.setObject(itemAttributes, forKey: indexPath)
//                        layoutInfo?.updateValue(itemAttributes, forKey: indexPath)
                            layoutInfo![indexPath] = itemAttributes
                    }
                }
                
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        
        var currentColumn = 0
        var maxHeight: CGFloat = 0
        do{
            var height: CGFloat = 0
            
            if let culumnHeight: AnyObject = lastYValueForColumn![currentColumn]
            {
                height = CGFloat(culumnHeight.doubleValue)
            }
        
            
            if maxHeight < height
            {
                maxHeight = height
            }
            currentColumn++
        
        }while(currentColumn < numberOfColumn)
        
        return CGSizeMake(self.collectionView!.bounds.width, maxHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
     
            var allAttributes = NSMutableArray(capacity: self.layoutInfo!.count)

//            self.layoutInfo?.enumerateKeysAndObjectsUsingBlock({(indexPath, attributes, stop) -> Void in
//                
//                if CGRectIntersectsRect(rect, (attributes as! UICollectionViewLayoutAttributes).frame)
//                {
//                    if let selectIndexPath = self.indexPath
//                    {
//                        if self.indexPath!.isEqual(indexPath as AnyObject) == false
//                        {
//                            allAttributes.addObject(attributes)
//                        }
//                    }
//                    else
//                    {
//                        allAttributes.addObject(attributes)
//                    }
//                }
//            })
        
        if let layoutInfo = self.layoutInfo {
            for (indexPath,attributes) in layoutInfo {
                if CGRectIntersectsRect(rect, attributes.frame) {
                    if let selectIndexPath = self.indexPath {
                        if !selectIndexPath.isEqual(indexPath) {
                            allAttributes.addObject(attributes)
                        }
                    }
                    else {
                        allAttributes.addObject(attributes)
                    }
                }
            }
        }
        
        
           if let selectIndexPath = self.indexPath
           {
             allAttributes.addObjectsFromArray(self.animator!.itemsInRect(rect))
            }
            
            println(allAttributes.count)
            
            return allAttributes as [AnyObject]
        
    
    }
    
//    override func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
//        
//        super.prepareForCollectionViewUpdates(updateItems)
//        deleteIndexPaths = NSMutableArray()
//
//        for updateItem in updateItems
//        {
//            let update: UICollectionViewUpdateItem = updateItem as! UICollectionViewUpdateItem
//            
//            if update.updateAction == UICollectionUpdateAction.Delete
//            {
//                self.deleteIndexPaths?.addObject(update)
//            }
//            
//        }
//        
//    }
//    
//    
//    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        
//        var attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
//        if deleteIndexPaths!.containsObject(itemIndexPath)
//        {
//            if let attribute = attributes
//            {
//                
//            }else
//            {
//                attributes = self.layoutInfo?.objectForKey(itemIndexPath) as? UICollectionViewLayoutAttributes
//            }
//        }
//        return attributes
//    }
//    
//    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        
//        var attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
//        if deleteIndexPaths!.containsObject(itemIndexPath)
//        {
//            if let attribute = attributes
//            {
//                
//            }else
//            {
//                attributes = self.layoutInfo?.objectForKey(itemIndexPath) as? UICollectionViewLayoutAttributes
//            }
//        }
//        return attributes
//        
//        
//    }
//    
//    
//    override func finalizeCollectionViewUpdates() {
//        
//        super.finalizeCollectionViewUpdates()
//        deleteIndexPaths = nil
//    }
    
    func updateDragLocation(location: CGPoint)
    {
        self.behavior?.anchorPoint = location
    }
    
    func stopDrag()
    {
        isDrag = false
        var attributes = self.layoutInfo![indexPath!] as! UICollectionViewLayoutAttributes
        updateDragLocation(attributes.center)
        self.indexPath = nil
        self.behavior = nil
        
    }
    
    
    func startDraggingIndexPath(#indexPath: NSIndexPath, fromPoint point: CGPoint)
    {
        isDrag = true
        
        self.indexPath = indexPath
        self.animator = UIDynamicAnimator(collectionViewLayout: self)
        var attributes = self.layoutInfo![indexPath] as! UICollectionViewLayoutAttributes
        attributes.zIndex += 1

        self.behavior = UIAttachmentBehavior(item: attributes, attachedToAnchor: point)
        self.behavior?.frequency = 10
        self.behavior?.length = 0
        self.animator?.addBehavior(self.behavior)

        var behaviorItem = UIDynamicItemBehavior(items: [attributes])
        behaviorItem.resistance = 10
        self.animator?.addBehavior(behaviorItem)

        updateDragLocation(point)
        println(point)
        
    }
    
}


//extension Int: NSCopying {
//    
//    func public copyWithZone(zone: NSZone) -> AnyObject {
//        return 2
//    }
//    
//}





























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
    func collectionView(_ collectionView:UICollectionView, layout: ScanViewLayout, heightForItemAtIndexPath indexPath:IndexPath)->CGFloat
}

class ScanViewLayout: UICollectionViewLayout {
   
    fileprivate var lastYValueForColumn = Dictionary<Int,AnyObject>()
    fileprivate var layoutInfo = Dictionary<IndexPath,UICollectionViewLayoutAttributes>()
    fileprivate var indexPath: IndexPath?
    fileprivate var animator: UIDynamicAnimator?
    fileprivate var behavior: UIAttachmentBehavior?
    fileprivate var deleteIndexPaths: NSMutableArray?
    fileprivate var insertIndexPaths: NSMutableArray?
    
    var numberOfColumn: NSInteger!
    var interItemSpacing: CGFloat!
    var delegate: MKMasonryViewLayoutDelegate?
    var isDrag: Bool = false
    
    override func prepare() {
        
        super.prepare()
        
        lastYValueForColumn = [:]
        layoutInfo  = [:]
        numberOfColumn = 1
        interItemSpacing = 0
        var currentColumn: Int = 0
        let fullWidth = collectionView?.bounds.width
        let availableSpaceExcludingPadding: CGFloat = fullWidth! - interItemSpacing * (CGFloat(numberOfColumn!) + 1)
        let itemWith: CGFloat = availableSpaceExcludingPadding / CGFloat(numberOfColumn)
        
        let numSections = self.collectionView?.numberOfSections
        
        if let numSections = numSections
        {
            for section in 0..<numSections
            {
                let numItems = self.collectionView?.numberOfItems(inSection: section)
                
                if let numItems = numItems
                {
                    for itemIndex in 0..<numItems
                    {
                        let indexPath = IndexPath(item: itemIndex, section: section)
                        
                        let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                        let x = interItemSpacing + (interItemSpacing + itemWith) * CGFloat(currentColumn)
                        
                        var y: CGFloat = 0
                        
                        if let obj: AnyObject = lastYValueForColumn[currentColumn]
                        {
                            y = CGFloat(obj as! NSNumber)
                        }
                        
                        
                        let height: CGFloat = (self.collectionView?.delegate as! MKMasonryViewLayoutDelegate).collectionView(collectionView!, layout: self, heightForItemAtIndexPath: indexPath)
                        itemAttributes.frame = CGRect(x: x, y: y, width: itemWith, height: height)
                        y += height
                        y += interItemSpacing
                        
                        lastYValueForColumn[currentColumn] = y as AnyObject?
                        currentColumn += 1
                        if currentColumn == numberOfColumn
                        {
                            currentColumn = 0
                        }
                        layoutInfo[indexPath] = itemAttributes
                    }
                }
                
            }
        }
    }
    
    override var collectionViewContentSize : CGSize {
        
        
        var currentColumn = 0
        var maxHeight: CGFloat = 0
        repeat {
            var height: CGFloat = 0
            
            if let culumnHeight: AnyObject = lastYValueForColumn[currentColumn]
            {
                height = CGFloat(culumnHeight.doubleValue)
            }
        
            
            if maxHeight < height
            {
                maxHeight = height
            }
            currentColumn += 1
        
        } while (currentColumn < numberOfColumn)
        
        return CGSize(width: self.collectionView!.bounds.width, height: maxHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
     
            let allAttributes = NSMutableArray(capacity: self.layoutInfo.count)

            for (indexPath,attributes) in layoutInfo {
                if rect.intersects(attributes.frame) {
                    if let selectIndexPath = self.indexPath {
                        if selectIndexPath != indexPath as! IndexPath {
                            allAttributes.add(attributes)
                        }
                    }
                    else {
                        allAttributes.add(attributes)
                    }
                }
            }
        
           if let selectIndexPath = self.indexPath
           {
             allAttributes.addObjects(from: self.animator!.items(in: rect))
            }
            
            print(allAttributes.count)
            
            return allAttributes as? [UICollectionViewLayoutAttributes]
        
    
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
    
    func updateDragLocation(_ location: CGPoint)
    {
        self.behavior?.anchorPoint = location
    }
    
    func stopDrag()
    {
        isDrag = false
        let attributes = self.layoutInfo[indexPath!] as! UICollectionViewLayoutAttributes
        updateDragLocation(attributes.center)
        self.indexPath = nil
        self.behavior = nil
        
    }
    
    
    func startDraggingIndexPath(indexPath: IndexPath, fromPoint point: CGPoint)
    {
        isDrag = true
        
        self.indexPath = indexPath
        self.animator = UIDynamicAnimator(collectionViewLayout: self)
        let attributes = self.layoutInfo[indexPath] as! UICollectionViewLayoutAttributes
        attributes.zIndex += 1

        self.behavior = UIAttachmentBehavior(item: attributes, attachedToAnchor: point)
        self.behavior?.frequency = 10
        self.behavior?.length = 0
        self.animator?.addBehavior(self.behavior!)

        let behaviorItem = UIDynamicItemBehavior(items: [attributes])
        behaviorItem.resistance = 10
        self.animator?.addBehavior(behaviorItem)

        updateDragLocation(point)
        print(point)
        
    }
    
}































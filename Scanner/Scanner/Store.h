//
//  Store.h
//  CoreDataDemo
//
//  Created by pfl on 15/5/26.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ScanItem;
@class NSManagedObjectContext;
@class NSFetchedResultsController;
@interface Store : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedContext;
//- (ScanItem*)scanItem;
- (NSFetchedResultsController*)getFetchResultsControllers;
@end

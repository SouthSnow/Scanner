//
//  PersistentStack.h
//  CoreDataDemo
//
//  Created by pfl on 15/5/26.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PersistentStack : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedContext;
@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSURL *storeURL;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL options:(NSDictionary*)options;
@end

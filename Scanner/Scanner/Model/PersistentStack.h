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
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL updateContextWithUbiquitousContentUpdates;
- (id)initWithStoreName:(NSString *)storeName modelName:(NSString *)modeName options:(NSDictionary*)options;
@end

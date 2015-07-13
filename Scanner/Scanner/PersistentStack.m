//
//  PersistentStack.m
//  CoreDataDemo
//
//  Created by pfl on 15/5/26.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "PersistentStack.h"
@interface PersistentStack ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedContext;


@end

@implementation PersistentStack

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL options:(NSDictionary*)options
{
    if (self = [super init]) {
        _modelURL = modelURL;
        _storeURL = storeURL;
        _options = options;
        [self setupManagedObjectContext];
    
    }

    return self;
}



- (void)setupManagedObjectContext
{
    self.managedContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.managedObjectModel];
    NSError *error;
    [self.managedContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:self.options error:&error];
    if (error) {
        
        NSLog(@"error :%@",error.localizedDescription);
        
    }
    
    self.managedContext.undoManager = [[NSUndoManager alloc]init];
    
}


- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc]initWithContentsOfURL:self.modelURL];
}

- (NSFetchedResultsController*)fetchResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self.class entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithValue:YES];
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"scanDate>0"];//满足一定条件的查询过滤
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc]initWithKey:@"scanDate" ascending:false]];// 根据某个字段进行排序,,,这是必须的要设置的
    
    return [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedContext sectionNameKeyPath:nil cacheName:nil];
}

+ (NSString*)entityName
{
    return @"ScanItem";
}


@end

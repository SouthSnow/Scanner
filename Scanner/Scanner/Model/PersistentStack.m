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
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PersistentStack

- (id)initWithStoreName:(NSString *)storeName modelName:(NSString *)modelName options:(NSDictionary*)options
{
    if (self = [super init]) {
        _modelName = modelName;
        _storeName = storeName;
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

- (NSURL*)storeURL
{
    NSURL *url = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.storeName]];
    return url;
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc]initWithContentsOfURL:self.modelURL];
}

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle]URLForResource:self.modelName withExtension:@"momd"];
}

- (NSFetchedResultsController*)fetchedResultsController
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


- (void)setUpdateContextWithUbiquitousContentUpdates:(BOOL)updateContextWithUbiquitousContentUpdates
{
    _updateContextWithUbiquitousContentUpdates = updateContextWithUbiquitousContentUpdates;
    if (updateContextWithUbiquitousContentUpdates) {
        [self registerForiCloudNotification];
    }
}

- (void)registerForiCloudNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:self.managedContext.persistentStoreCoordinator];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(persistentStoreDidImportUbiquitousContentChange:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:self.managedContext.persistentStoreCoordinator];
}

- (void)persistentStoreDidImportUbiquitousContentChange:(NSNotification*)notification
{
    [self.managedContext performBlock:^{
        [self.managedContext mergeChangesFromContextDidSaveNotification:notification];
        NSLog(@"mergeChangesFromContextDidSaveNotification");
    }];
}

@end









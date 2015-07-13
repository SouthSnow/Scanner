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
@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation PersistentStack

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL
{
    if (self = [super init]) {
        _modelURL = modelURL;
        _storeURL = storeURL;
        
        [self setupManagedObjectContext];
    
    }

    return self;
}



- (void)setupManagedObjectContext
{
    self.managedContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.managedObjectModel];
    NSError *error;
    [self.managedContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error];
    if (error) {
        
        NSLog(@"error :%@",error.localizedDescription);
        
    }
    
    
    self.managedContext.undoManager = [[NSUndoManager alloc]init];
    
}


- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc]initWithContentsOfURL:self.modelURL];
}

@end

//
//  Store.m
//  CoreDataDemo
//
//  Created by pfl on 15/5/26.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "Store.h"
#import <CoreData/CoreData.h>
#import "ScanItem.h"

@implementation Store

- (ScanItem *)scanItem
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ScanItem"];
    request.predicate = [NSPredicate predicateWithValue:YES];
    NSArray *objects = [self.managedContext executeFetchRequest:request error:NULL];
    ScanItem *item = [objects lastObject];
    if (!item) {
        
        item = [ScanItem insertShopIncomeItem:nil inManagedObjectContext:self.managedContext];

    }

    
    NSLog(@"item:%p",item);
    
    return item;
    
}

- (NSFetchedResultsController*)getFetchResultsControllers
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

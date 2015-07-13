//
//  ScanItem.m
//  Scanner
//
//  Created by pfl on 15/6/3.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

#import "ScanItem.h"


@implementation ScanItem

@dynamic scanDate;
@dynamic scanDetail;

+ (instancetype)insertShopIncomeItem:(ScanItem*)item inManagedObjectContext:(NSManagedObjectContext*)managedContext
{
    
    ScanItem *scanItem = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:managedContext];
    
    scanItem.scanDate = item.scanDate;
    scanItem.scanDetail = item.scanDetail;
    
    
    return scanItem;
    
}

//- (NSFetchedResultsController*)getFetchResultsControllers
//{
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self.class entityName]];
//    fetchRequest.predicate = [NSPredicate predicateWithValue:YES];
////    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"scanDate>0"];//满足一定条件的查询过滤
//    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc]initWithKey:@"scanDate" ascending:false]];// 根据某个字段进行排序,,,这是必须的要设置的
//    
//    return [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//}

+ (NSString*)entityName
{
    return @"ScanItem";
}


@end

//
//  SWDispatchTool.h
//  Wallet
//
//  Created by swifter on 2018/1/3.
//  Copyright © 2018年 SwiftPass. All rights reserved.
//

#ifndef SWDispatchTool_h
#define SWDispatchTool_h

static const char *serialQueueLabel = "com.pflnh.SerialQueue";
static const char *concurrentQueueLabel = "com.pflnh.ConcurrentQueue";
static const char *seriakVideoQueueLabel = "com.pflnh.video.ConcurrentQueue";

/**
 获取主线程
*/
static inline dispatch_queue_t SWDispatchMainQueue(void) {
    return dispatch_get_main_queue();
}

/**
 获取globalQueue
 */
static inline dispatch_queue_t SWDispatchGlobalDefaultQueue(void) {
    return dispatch_get_global_queue(0, 0);
}

/**
 延迟afterInterval时间搞事情

 @param afterInterval 延迟的时间
 @param block 搞事情
 */
static inline void SWDispatchAfterDoSomething(NSTimeInterval afterInterval, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

/**
 在主线程搞事情

 @param block 搞事情
 */
static inline void SWRunOnMainThreadDo(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        if (block) {
            block();
        }
    }
    else {
        dispatch_async(SWDispatchMainQueue(), block);
    }
}

static inline void SWRunOnGlobalThreadDoSomething(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

/**
 创建一个同步queue

 @param label queue标签
 @return 同步queue
 */
static inline dispatch_queue_t SWCreateSerialQueue(const char *label) {
    static dispatch_once_t onceToken;
    static dispatch_queue_t serialQueue = nil;
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create(label, NULL/*DISPATCH_QUEUE_SERIAL*/);
    });
    return serialQueue;
}

/**
 创建并发queue

 @param label queue标签
 @return 并发queue
 */
static inline dispatch_queue_t SWCreateConcurrentQueue(const char *label) {
    static dispatch_once_t onceToken;
    static dispatch_queue_t concurrentQueue = nil;
    dispatch_once(&onceToken, ^{
        concurrentQueue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
    });
    return concurrentQueue;
}


/**
 异步并发搞事

 @param task 搞事情
 */
static inline void SWCreateCustomConcurrentQueueDoSomething(dispatch_block_t task) {
    dispatch_async(SWCreateConcurrentQueue(concurrentQueueLabel), task);
}
/**
 异步串行搞事情
 
 @param task 搞事情
 */
static inline void SWCreateCustomSerialQueueDoSomething(dispatch_block_t task) {
    dispatch_async(SWCreateSerialQueue(serialQueueLabel), task);
}

static inline void SWCreateCustomSerialQueueDoSomethingWithLabel(char *label, dispatch_block_t task) {
    dispatch_async(SWCreateSerialQueue(label), task);
}

static inline void SWCreateVideoSerialQueueDo(dispatch_block_t task) {
    dispatch_async(SWCreateSerialQueue(seriakVideoQueueLabel), task);
}


/**
 一个自定义队列，一个任务，异步执行

 @param queue 自定义队列
 @param task 任务
 */
static inline void SWAsyncWithQueue(dispatch_queue_t queue, dispatch_block_t task) {
    dispatch_async(queue, task);
}

/**
 一个自定义队列，一个任务，同步执行
 
 @param queue 自定义队列
 @param task 任务
 */
static inline void SWSyncWithQueue(dispatch_queue_t queue, dispatch_block_t task) {
    dispatch_sync(queue, task);
}



#endif /* SWDispatchTool_h */

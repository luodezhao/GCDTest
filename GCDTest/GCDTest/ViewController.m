//
//  ViewController.m
//  GCDTest
//
//  Created by YB on 16/1/12.
//  Copyright © 2016年 YB. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    dispatch_queue_t qu;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self selfCreateQueue];
//    [self testSetTargetQueue];
//    [self testAfter];
//    [self testGroup];
//    [self testBarrier];
//    [self testApply];
//    [self testSuspend];
//    [self testSem];
//    [self testOnce];
//    [self testOnce];
//    [self timerTest];
//    [self sourceTest];
//    [self addTest];。、。、
    
}
- (void)selfCreateQueue {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.GCDTest.MySeialQueue", DISPATCH_QUEUE_SERIAL);//这里第一个参数是名字，第二个参数是队列类型。
   dispatch_sync(serialQueue, ^{
       NSLog(@"1");
       NSLog(@"%@",[NSThread currentThread]);
   });
    NSLog(@"2");
    //主线程的queue
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{//这里要用async，不然要死锁
        NSLog(@"3");
    });
   
    //不同优先级的currentQueue
    dispatch_queue_t currentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//这里后面传0，官方文档说的。

    dispatch_async(currentQueue, ^{
        NSLog(@"4");
    });
    NSLog(@"6");
   
  }
- (void)testSetTargetQueue {
    dispatch_queue_t currentQueue1 = dispatch_queue_create("456", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t currentQueue2 = dispatch_queue_create("789", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t curentQueuelow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(currentQueue1, curentQueuelow);
    dispatch_async(currentQueue1, ^{
        NSLog(@"2");
    });
    dispatch_async(currentQueue2, ^{
        NSLog(@"3");
    });
}
- (void)testAfter {
    //不是在指定时间后处理，而是在指定时间追加到dispathchqueue；
dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);//第一个参数表示现在的时间，第二个参数表示指定的毫秒单位时间后的时间 数值 *NSEC_PER_SEC 得到单位为毫微秒的数值，ull表示（unsigned long long）
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"1");
    });
    NSLog(@"2");
//    [NSThread sleepForTimeInterval:5];
    NSLog(@"3");
}
- (void)testGroup {
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
       dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue1, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, queue1, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"3");
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"4");
    });
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{//属于group的全部处理在追加追定的block时都已经全部结束
    NSLog(@"5");
});
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER);//第一个参数表示现在的时间，第二个参数表示

    long resutl =   dispatch_group_wait(group,time );
    if (!resutl) {
        NSLog(@"6");
    }


    
}
- (void)testBarrier {
    //在文件写取时，使用串行队列可避免数据竞争的问题，但是多个并行队列读取文件，并不会有什么问题。
    //dispatch_barrier_async,会等待追加到concurrent dis queue 上的并行执行的处理全部结束之后，再将指定的处理，加到queue中。并且，这个函数操做完之后，再恢复一般的动作。
//    dispatch_queue_t queue = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"1");
    });

    dispatch_async(queue, ^{
        NSLog(@"2");
    });

    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
         
        NSLog(@"3");
    });

    dispatch_async(queue, ^{
        
        NSLog(@"4");
    });
dispatch_barrier_async(queue, ^{
    NSLog(@"here");
});
    dispatch_async(queue, ^{
        NSLog(@"5");
    });
    dispatch_async(queue, ^{
        NSLog(@"6");
    });

}
- (void)testApply {
    //dispatch_apply是dispatch_snyc和dispatch group关联的api，按指定的次数将指定的block追加到指定的dispatch queue中
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {//第一个参数是重复次数，第二个参数是追加对象，第三个参数，追加的任务
        //这个函数与dispatch_sync相同，会等待处理执行的结束，因此推荐的dispatch_async中非同步执行
        NSLog(@"%zu",index);
    });
    NSLog(@"10");
}
- (void)testSuspend {
    //有时希望不执行已经追加的处理
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = dispatch_queue_create("1", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"1");
        dispatch_sync(dispatch_get_main_queue(), ^{
            dispatch_suspend(queue);
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3");
            dispatch_resume(queue);
            
        });
    });
    dispatch_async(queue, ^{
        NSLog(@"2");
    });

    

}

- (void)testSem {
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
//    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);//等待sema的技术值大于或等于1，当技术值大于或等于1，对该技术进行减去并从这个函数返回，返回值和dispatch_group_wait返回值相同，
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"1");
        dispatch_semaphore_signal(sema);
    });
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        [NSThread sleepForTimeInterval:1];
        NSLog(@"2");
        dispatch_semaphore_signal(sema);
    });
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"3");
        dispatch_semaphore_signal(sema);
    });
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"4");
        dispatch_semaphore_signal(sema);
    });


}
- (void)testOnce {
    static dispatch_once_t once;
    dispatch_once(&once,^{
        NSLog(@"1");
    });
}
- (void)testIO {
    dispatch_queue_t queue = dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_fd_t fd =
//    dispatch_fd_t
    dispatch_io_t queueChannel = dispatch_io_create(DISPATCH_IO_STREAM, 1, queue, ^(int error) {
        close(1);
    });
    dispatch_io_set_low_water(queueChannel, SIZE_MAX);
    dispatch_io_read(queueChannel, 0, SIZE_MAX, queue, ^(bool done, dispatch_data_t data, int error) {
        size_t len = dispatch_data_get_size(data);
        if (len > 0) {
            const char *bytes = nil;
            char *encoded;
            dispatch_data_t md = dispatch_data_create_map(data, &bytes, &len);
//            encoded = asl_core_encode_buffer
        }
    });
    //多个线程去读取文件的切片数据
}
- (void)apply {
    //dispatch_queue 通过结构体和链表，被实现为fifo队列，而block也不是直接加入fifo队列，而是先加入dispatch continuation这一dispatch_continuation_t类型的结构体中，然后再加入队列，这个continuation用于记忆block所属的group等信息，相当于执行上下文
//    当queue执行block时，libdispatch从queue自身的队列中取出dispatch continuation，调用-个函数（pthread——woekqueue——additem——up）,将该queue自身，符合其优先级的workqueue信息以及为执行dispatch continuation的回掉函数等传递给参数，通知workqueue增加应当执行的项目。xnu基于系统状态判断是否生成线程。wprkqueue的线程执行pthread—workqueue函数，该函数调用ibdispatch的回调函数，在该回调中，执行加入到dispatchcontinuation的block
//    block结束后，通知dispatch group 结束，释放dispatch continuation等chul，开始准备执行下一个block
}
- (void)sourceTest {
    //事情发生时，在指定的dispatch queue中可执行事件的处理。
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"%@",path);
       NSString *a = [path stringByAppendingPathComponent:@"1"];
    int fd = open([a fileSystemRepresentation], O_EVTONLY);
    NSLog(@"%d",fd);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_DELETE|DISPATCH_VNODE_WRITE, DISPATCH_TARGET_QUEUE_DEFAULT);

    if (fd < 0) {
        NSLog(@"打开失败");
    }else {
//        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_DELETE|DISPATCH_VNODE_WRITE, dispatch_get_main_queue());
        dispatch_source_set_event_handler(source, ^{
            long long data = dispatch_source_get_data(source);
            if (data) {
                NSLog(@"changed");
            }

        });
    }
     dispatch_resume(source);//source启动默认状态下是挂起的
    [path writeToFile:[path stringByAppendingPathComponent:@"1"]  atomically:YES encoding:NSUTF8StringEncoding error:nil];


}
- (void)timerTest {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 3 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"1");
//        dispatch_source_cancel(timer);
    });
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"2");
    });
    dispatch_resume(timer);
}
- (void)addTest {
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        NSLog(@"%ld",dispatch_source_get_data(source));
    });
    dispatch_resume(source);
    dispatch_source_merge_data(source, 1);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

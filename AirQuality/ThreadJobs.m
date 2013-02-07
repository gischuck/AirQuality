//
//  ThreadJobs.m
//  AirQuality
//
//  Created by WenHao on 13-1-17.
//  Copyright (c) 2013年 WenHao. All rights reserved.
//

#import "ThreadJobs.h"

static ThreadJobs *_threadJobs;

@implementation ThreadJobs

- (id) init
{
	if (self = [super init])
	{
        ThreadGetCurrentState = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        lockCondition = [[NSCondition alloc] init];
        _valueHelper = [ValueHelper valueHelperInstance];
        [ThreadGetCurrentState setName:@"CheckCurrentState"];
        [ThreadGetCurrentState start];
	}
	return self;
}

+ (ThreadJobs *)ThreadInstance
{
    if (!_threadJobs)
	{
		_threadJobs = [[ThreadJobs alloc] init];
	}
	return _threadJobs;
}

//刷新信息 600s
- (void)run{
    while (TRUE) {
        // 上锁
        [lockCondition lock];
        [_valueHelper loadJsonData:[NSURL URLWithString:kBjAirUrl]];
        NSLog(@"thread process");
        //间隔时间
        [NSThread sleepForTimeInterval:600];
        
        //解锁
        [lockCondition unlock];
    }
}

@end

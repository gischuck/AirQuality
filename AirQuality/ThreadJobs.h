//
//  ThreadJobs.h
//  AirQuality
//
//  Created by WenHao on 13-1-17.
//  Copyright (c) 2013年 WenHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValueHelper.h"

@interface ThreadJobs : NSObject
{
    NSThread *ThreadGetCurrentState;
    NSCondition *lockCondition;
    ValueHelper *_valueHelper;
}

+(ThreadJobs *)ThreadInstance;
@end

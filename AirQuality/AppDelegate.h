//
//  AppDelegate.h
//  AirQuality
//
//  Created by WenHao on 13-1-17.
//  Copyright (c) 2013年 WenHao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ValueHelper.h"
#import "ThreadJobs.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    ThreadJobs *checkJobs;
}
@property (assign) IBOutlet NSWindow *window;

@end

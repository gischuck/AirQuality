//
//  AppDelegate.m
//  AirQuality
//
//  Created by WenHao on 13-1-17.
//  Copyright (c) 2013年 WenHao. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    //启动线程
    checkJobs = [ThreadJobs ThreadInstance];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

//Click Dock Show App
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    [self.window makeKeyAndOrderFront:self];
    if (flag) {
        return NO;
    }
    return YES;
}
@end

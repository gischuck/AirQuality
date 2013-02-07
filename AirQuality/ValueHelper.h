//
//  ValueHelper.h
//  AirQuality
//
//  Created by WenHao on 13-1-17.
//  Copyright (c) 2013年 WenHao. All rights reserved.
//

#define kGlobalQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define kBjAirUrl @"http://zx.bjmemc.com.cn/ashx/Data.ashx?Action=GetAQIClose1h"

#import <Foundation/Foundation.h>

@interface ValueHelper : NSObject<NSComboBoxDelegate>
{
    BOOL firstStart;
    NSInteger selectIndex;
    NSMutableArray *stationName;
    NSMutableArray *stationInfo;
    NSImage *image;
}
@property (weak) IBOutlet NSTextField *aqiName;
@property (weak) IBOutlet NSTextField *aqiValue;
@property (weak) IBOutlet NSTextField *qValue;
@property (weak) IBOutlet NSTextField *quality;
@property (weak) IBOutlet NSTextField *time;

@property (weak) IBOutlet NSProgressIndicator *indicator;

@property (weak) IBOutlet NSComboBox *stationComboBox;
@property (weak) IBOutlet NSImageView *imageView;

- (NSColor *) colorWithHexString: (NSString *) hexString;

+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

+ (ValueHelper *)valueHelperInstance;

- (void)loadJsonData:(NSURL *)url;

@end

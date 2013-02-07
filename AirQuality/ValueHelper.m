//
//  ValueHelper.m
//  AirQuality
//
//  Created by WenHao on 13-1-17.
//  Copyright (c) 2013年 WenHao. All rights reserved.
//

#import "ValueHelper.h"

static ValueHelper *_valueHelperInstance;

@implementation ValueHelper

- (id) init
{
	if (self = [super init])
	{
        firstStart = YES;
        selectIndex = 0;
        [self.indicator startAnimation:self];
        [self.stationComboBox removeAllItems];
        [self loadJsonData:[NSURL URLWithString:kBjAirUrl]];
        [self.indicator stopAnimation:self];
    }
	return self;
}

//类进程
+ (ValueHelper *)valueHelperInstance
{
    if (!_valueHelperInstance)
	{
		_valueHelperInstance = [[ValueHelper alloc] init];
	}
	return _valueHelperInstance;
}

//下拉框选择
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    @try {
        [self.indicator startAnimation:self];
        selectIndex = [(NSComboBox *)[notification object] indexOfSelectedItem];
        NSLog(@"you select %ld, %@", selectIndex,[stationInfo objectAtIndex:selectIndex]);
        [self getInfo:selectIndex];
        [self showStateColor];
        //保存选择数据，下次启动自动选择
        if (!firstStart) {
            NSArray *array = [[NSArray alloc]initWithObjects:[stationName objectAtIndex:selectIndex], nil];
            [self saveData:array];

        }
        [self.indicator stopAnimation:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

//从网络上获取空气质量信息
- (void)loadJsonData:(NSURL *)url
{
    @try {
        dispatch_async(kGlobalQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            [self performSelectorOnMainThread:@selector(parseJsonData:) withObject:data waitUntilDone:NO];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
}

//解析json
- (void)parseJsonData:(NSData *)data 
{
    @try {
        NSError *error;
        stationName = [[NSMutableArray alloc] init];
        stationInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (stationInfo == nil) {
            NSLog(@"json parse failed \r\n");
            return;
        }
         for (int i=0; i<stationInfo.count; i++) {
            NSDictionary *stationArray = [stationInfo objectAtIndex:i];
            [stationName addObject:[stationArray objectForKey:@"StationName"]];
        }
        
        [self.stationComboBox removeAllItems];
        [self.stationComboBox addItemsWithObjectValues:stationName];

        [self.stationComboBox reloadData];
        //判断是否第一次加载程序
        if (stationName.count > 0 && firstStart == YES) {
            [self.stationComboBox selectItemAtIndex:0];
            firstStart = NO;
            
            //读取保存的数据
            NSString *Path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
            Path = [Path stringByAppendingFormat:@"/AirQuality"];
            BOOL isDirectory = NO;
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDirectory];
            if (!exists) {
                [[NSFileManager defaultManager] createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *filename = [Path stringByAppendingPathComponent:@"sav.cfg"];
            NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
            NSString *location = [arr objectAtIndex:0];
            [self.stationComboBox selectItemWithObjectValue:location];
        }
        else
        {
            [self.stationComboBox selectItemAtIndex:selectIndex];
        }
        NSLog(@"%ld", selectIndex);        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

//获取json信息
- (void)getInfo:(long)index
{
    @try {
        NSDictionary *info = [stationInfo objectAtIndex:index];
        
        NSString *tmp = [info objectForKey:@"AQIName"];
        
        if (tmp.length > 0) {
            [self.aqiName setStringValue:[[NSString alloc]initWithFormat:@"%@%@",tmp, @"："]];
        }
        else {
            [self.aqiName setStringValue: @"Unknown："];
        }
        
        tmp = [info objectForKey:@"AQIValue"];
        if (tmp.length > 0) {
            [self.aqiValue setStringValue:tmp];
        }
        else {
            [self.aqiValue setStringValue:@"Null"];
        }
        
        tmp = [info objectForKey:@"QLevel"];
        if (tmp.length > 0) {
            [self.qValue setStringValue:tmp];
        }
        else {
            [self.qValue setStringValue:@"Null"];
        }
        
        tmp = [info objectForKey:@"Quality"];
        if (tmp.length > 0) {
            [self.quality setStringValue:tmp];
        }
        else {
            [self.quality setStringValue:@"Null"];
        }
        
        tmp = [info objectForKey:@"Time"];
        if (tmp.length > 0) {
            [self.time setStringValue:tmp];
        }
        else {
            [self.time setStringValue:@"Null"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

//显示颜色函数
- (void)showStateColor
{
    NSDictionary *dict = [stationInfo objectAtIndex:selectIndex];
    NSString *colorStr = [dict objectForKey:@"RGB"];
    colorStr = [colorStr substringFromIndex:1];
    NSLog(@"%@", [self colorWithHexString:colorStr]);
    image = [[NSImage alloc] initWithSize:NSMakeSize(50, 50)];
    [image lockFocus];
    [[self colorWithHexString:colorStr] drawSwatchInRect:NSMakeRect(0, 0, 50, 50)];
    [image  unlockFocus];
    [self.imageView setImage:image];
}

//将Unicode转换为中文
+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

//将十六进制颜色转换为NSColor
- (NSColor *)colorWithHexString:(NSString *) inColorString
{
    NSColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;//, alphaByte
    
    if (inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode];

        redByte     = (unsigned char) (colorCode >> 16);
        greenByte   = (unsigned char) (colorCode >> 8);
        blueByte    = (unsigned char) (colorCode);
        
        result = [NSColor colorWithCalibratedRed:(float)redByte/0xff
                                           green:(float)greenByte/0xff
                                            blue:(float)blueByte/0xff
                                           alpha:1.0];
    }
    return result;
}

//保存选择的地址
- (void)saveData:(NSArray *)array
{
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:@"AirQuality/sav.cfg"];
    [NSKeyedArchiver archiveRootObject:array toFile:filename];
}

@end

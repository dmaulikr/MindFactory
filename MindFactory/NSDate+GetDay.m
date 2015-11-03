//
//  NSDate+GetDay.m
//  MindFactory
//
//  Created by sasha on 03.11.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "NSDate+GetDay.h"

@implementation NSDate (GetDay)


+ (NSString *)getDateStringWithDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterFullStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

+ (NSString *)getDayStringWithDate:(NSDate *)now
{
    //  NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    return [dateFormatter stringFromDate:now];
}

@end

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

#pragma mark - DateCompare
+ (NSString *)getStringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"d MMM yyyy, HH:mm"];
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    return stringFromDate;
}

+ (NSDate*)dayOnlyDateFromDate:(NSDate*)date
{
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:date];
    
    return [calendar dateFromComponents:components];
}

+ (BOOL)checkDateToSelected:(NSDate*)date checkDateToSelected:(NSDate*)date2
{
    NSString *dateString = [self getStringFromDate:[self dayOnlyDateFromDate:date]];
    NSString *dateSelectedString = [self  getStringFromDate:[self dayOnlyDateFromDate:date2]];
    
    if ([dateString  isEqualToString:dateSelectedString]){
        
        return true;
    }
    else
        return false;
}



@end

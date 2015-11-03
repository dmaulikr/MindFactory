//
//  NSDate+GetDay.h
//  MindFactory
//
//  Created by sasha on 03.11.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (GetDay)


+ (NSString *)getDateStringWithDate:(NSDate *)date;
+ (NSString *)getDayStringWithDate:(NSDate *)now;

@end

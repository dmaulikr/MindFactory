//
//  Note.h
//  Diary
//
//  Created by Mac on 14.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSData * noteDescription;
@property (nonatomic, retain) NSDate * timeStamp;


@end

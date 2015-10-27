//
//  Diary+CoreDataProperties.h
//  MindFactory
//
//  Created by sasha on 27.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Diary.h"

NS_ASSUME_NONNULL_BEGIN

@interface Diary (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *noteDescription;
@property (nullable, nonatomic, retain) NSDate *timeStamp;

@end

NS_ASSUME_NONNULL_END

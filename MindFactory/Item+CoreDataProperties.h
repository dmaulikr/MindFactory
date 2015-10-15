//
//  Item+CoreDataProperties.h
//  MindFactory
//
//  Created by sasha on 14.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSData *photo;
@property (nullable, nonatomic, retain) NSNumber *positive;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSNumber *value;

@end

NS_ASSUME_NONNULL_END

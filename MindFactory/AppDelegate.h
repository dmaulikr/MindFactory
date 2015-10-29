//
//  AppDelegate.h
//  Money
//
//  Created by sasha on 22.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Item.h"
#import "Note.h"
#import "Diary.h"


#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication]delegate]


@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController* notesFetchController;
@property (strong, nonatomic) NSFetchedResultsController* diaryFetchController;


//money
- (void)deleteItem:(Item *)deletingItem;
- (void)createNewItem:(NSNumber *)value andDate:(NSDate*)date andNotesDescription:(NSString *)note andPhoto:(NSData *)photo numberSign:(NSNumber *)sign;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


//notes
- (void)addNewNoteWithText:(NSData *)text;
- (void)removeNote:(NSManagedObject*)note;

//diary
- (void)addNewDiaryWithText:(NSData *)text;
- (void)removeDiary:(NSManagedObject*)diary;
- (void)moveNoteToDiary:(Note *)note;





@end


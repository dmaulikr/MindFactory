//
//  AppDelegate.m
//  Money
//
//  Created by sasha on 22.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "AppDelegate.h"
#import "MoneyViewController.h"
#import "NSDate+GetDay.h"
#import "LTHPasscodeViewController.h"

@interface AppDelegate () 


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



#pragma mark - CoreDataCheck

- (BOOL)coreDataHasEntriesForEntityName:(NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[APP_DELEGATE  managedObjectContext]];
    [request setEntity:entity];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [[APP_DELEGATE managedObjectContext] executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Fetch error: %@", error);
        abort();
    }
    if ([results count] == 0) {
        return NO;
    }
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    BOOL a = [self coreDataHasEntriesForEntityName:@"Diary"];
    NSLog(@"CHECK: %d", a);
    
    
    if ([self coreDataHasEntriesForEntityName:@"Diary"]) {
        
        //       NSArray *mass = [[APP_DELEGATE diaryFetchController]fetchedObjects];
        
        Diary* aDiary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:0];
        
        
        NSLog(@"%@", aDiary.timeStamp);
        
        NSDate *current = aDiary.timeStamp;
        NSDate *now = [NSDate date];
        
        
        while (true) {
            //check
            if ([NSDate checkDateToSelected:current checkDateToSelected:now]) {
                NSLog(@"Equals");
                break;
            }
            //end check
            
            //chek to future
            NSDate *today = [NSDate date];
            NSDate *compareDate = current;
            
            NSComparisonResult compareResult = [today compare : compareDate];
            
            if (compareResult == NSOrderedAscending)
            {
                NSLog(@"CompareDate is in the future");
                break;
            }
            
            //endcheck
            
            //add one day
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = 1;
            
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:current options:0];
            
            NSLog(@"nextDate: %@ ...", nextDate);
            //end
            //add to core data next day
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"" attributes:nil];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:str];
            
            
            NSNumber *numIndex = [NSNumber numberWithInteger:2];
            
            [self addNewDiaryWithText:data andDate:nextDate andIndexSmile:numIndex];
            //end
            
            //day up
            current = nextDate;
            //end
        }
        
    } else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"" attributes:nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:str];
        [self addNewDiaryWithText:data andIndexSmile:2];
    }
       
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize notesFetchController = _notesFetchController;
@synthesize diaryFetchController = _diaryFetchController;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "JSV.Money" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MindFactory" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MindFactory.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    [_managedObjectContext setRetainsRegisteredObjects:YES];
    
    return _managedObjectContext;
}

#pragma mark - FetchedResultsController
//fetched rezult controller i myself config
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //sort description
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"timeStamp" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    
    NSError *error = nil;
    
    if (![_fetchedResultsController performFetch:&error]) {
        
        NSLog(@"Error %@,\n %@", error, [error localizedDescription]);
    }
    
    return _fetchedResultsController;
}

//create ne Item
- (void)createNewItem:(NSNumber *)value andDate:(NSDate*)date andNotesDescription:(NSString *)note andPhoto:(NSData *) photo numberSign: (NSNumber *)sign
{
    NSManagedObjectContext *context = [[self fetchedResultsController] managedObjectContext];
    NSEntityDescription* entity = [[[self fetchedResultsController]fetchRequest]entity];
    Item *moneyInfo = [NSEntityDescription
                            insertNewObjectForEntityForName:[entity name]
                            inManagedObjectContext:context];

    moneyInfo.value = value;
    moneyInfo.timeStamp = date;
    moneyInfo.notes = note;
    moneyInfo.photo = photo;
    moneyInfo.positive = sign;
    
    
    [self saveContext];
}

//delete item
- (void)deleteItem:(Item *)deletingItem;
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:deletingItem];
    [self saveContext];
}

#pragma mark - NotesFetchedController
- (NSFetchedResultsController*)notesFetchController
{
    if (_notesFetchController) {
        
        return _notesFetchController;
    }
    
    NSEntityDescription* notesEntity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest* notesRequest = [[NSFetchRequest alloc]init];
    [notesRequest setEntity:notesEntity];
    
    NSSortDescriptor* dateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"timeStamp" ascending:NO];
    [notesRequest setSortDescriptors:@[dateSortDescriptor]];
    
    _notesFetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:notesRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    NSError* error = nil;
    if(![_notesFetchController performFetch:&error]){
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return _notesFetchController;
}

- (void)addNewNoteWithText:(NSData *)text;
{
    Note* theNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[self managedObjectContext]];
    
    theNote.noteDescription = text;
    theNote.timeStamp = [NSDate date];
    
    [self saveContext];
}

- (void)removeNote:(NSManagedObject*)note
{
    [[self managedObjectContext] deleteObject:note];
    [self saveContext];
}

#pragma mark - DiaryFetchedResultsController
- (NSFetchedResultsController *)diaryFetchController
{
    if (_diaryFetchController) {
        [_diaryFetchController performFetch:nil];
        return _diaryFetchController;
    }
    
    NSEntityDescription* diaryEntity = [NSEntityDescription entityForName:@"Diary" inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest* diaryRequest = [[NSFetchRequest alloc]init];
    [diaryRequest setEntity:diaryEntity];
    
    NSSortDescriptor* dateSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"timeStamp" ascending:NO];
    [diaryRequest setSortDescriptors:@[dateSortDescriptor]];
    
    _diaryFetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:diaryRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    NSError* error = nil;
    if(![_diaryFetchController performFetch:&error]){
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return _diaryFetchController;
}

#pragma mark - DiaryMethods
- (void)addNewDiaryWithText:(NSData *)text andIndexSmile:(NSInteger)index;
{
    Diary* theDiary = [NSEntityDescription insertNewObjectForEntityForName:@"Diary" inManagedObjectContext:[self managedObjectContext]];
    
    
    
    NSNumber *indexNumber = [NSNumber numberWithInteger:index];
    
    theDiary.noteDescription = text;
    theDiary.indexSmile = indexNumber;
    theDiary.timeStamp = [NSDate date];
    
    [self saveContext];
}

- (void)addNewDiaryWithText:(NSData *)text andDate:(NSDate *)date andIndexSmile:(NSNumber *)index;
{
    Diary* theDiary = [NSEntityDescription insertNewObjectForEntityForName:@"Diary" inManagedObjectContext:[self managedObjectContext]];
    
    
    theDiary.noteDescription = text;
    theDiary.indexSmile = index;
    theDiary.timeStamp = date;
    
    [self saveContext];
}



- (void)removeDiary:(NSManagedObject*)diary
{
    [[self managedObjectContext] deleteObject:diary];
    [self saveContext];
}

- (void)moveNoteToDiary:(Note *)note
{
    Diary *theDiary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:0];

    
    NSMutableAttributedString *diaryString =
    [NSKeyedUnarchiver unarchiveObjectWithData: theDiary.noteDescription];
    
    NSAttributedString *noteString =
    [NSKeyedUnarchiver unarchiveObjectWithData: note.noteDescription];
    
    [[self managedObjectContext] deleteObject:note];
    

    
    NSLog(@"%@", diaryString);
    NSMutableAttributedString *newLine = [[NSMutableAttributedString alloc]initWithString:@"\n"];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithAttributedString:diaryString];
    [message appendAttributedString:newLine];
    [message appendAttributedString:noteString];
    
    NSLog(@"%@", message);
    
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: message];
    theDiary.noteDescription = data;
   
    [self saveContext];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    @try {
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil) {
            [managedObjectContext performBlockAndWait:^{
                NSError *error = nil;
                if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
        
            }];
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}

@end

//
//  NotesTableController.m
//  Diary
//
//  Created by Mac on 11.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import "NotesTableController.h"
#import "NoteDesciriptionController.h"
#import "NoteCell.h"
#import "Note.h"
#import "NSString+Heigh.h"
#import "AppDelegate.h"
#import "LTHPasscodeViewController.h"
#import "DiaryTableViewController.h"

#define cellSegue @"cellSegue"
#define addSegue @"addSegue"
#define diarySegue @"diarySegue"


@interface NotesTableController ()
<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, LTHPasscodeViewControllerDelegate>
{
    //PasscodeViewController
    LTHPasscodeViewController *_passcodeController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotesTableController
{

    NSArray *searchResults;
}

@synthesize tableView = _tableView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL a = [self coreDataHasEntriesForEntityName:@"Diary"];
    NSLog(@"CHECK: %d", a);
    
    
    if ([self coreDataHasEntriesForEntityName:@"Diary"]) {
        
        NSArray *mass = [[APP_DELEGATE diaryFetchController]fetchedObjects];
        
        Diary* aDiary = [mass objectAtIndex:0];
        
        
        NSLog(@"%@", aDiary.timeStamp);
        
        NSDate *current = aDiary.timeStamp;
        NSDate *now = [NSDate date];
        
        
        while (true) {
            //check
            if ([self checkDateToSelected:current checkDateToSelected:now]) {
                NSLog(@"Equals");
                break;
            }
            //end check
            
            //add one day
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = 1;
            
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:current options:0];
            
            NSLog(@"nextDate: %@ ...", nextDate);
            //end
            //add to core data next day
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"StringTest" attributes:nil];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:str];
            [APP_DELEGATE addNewDiaryWithText:data andDate:nextDate];
            //end
            
            //day up
            current = nextDate;
            //end
        }
        
    } else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"" attributes:nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:str];
        [APP_DELEGATE addNewDiaryWithText:data andIndexSmile:2];
    }
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[APP_DELEGATE notesFetchController] setDelegate: self];
    //research
    self.searchDisplayController.searchBar.text =  self.searchDisplayController.searchBar.text;
    
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"rootViewController: viewDidAppear");
    [super viewDidAppear:animated];
  
    // reload table
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - DateCompare
-(NSString *)getStringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"d MMM yyyy, HH:mm"];
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    return stringFromDate;
}

- (NSDate*)dayOnlyDateFromDate:(NSDate*)date
{
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:date];
    
    return [calendar dateFromComponents:components];
}

-(BOOL)checkDateToSelected:(NSDate*)date checkDateToSelected:(NSDate*)date2
{
    NSString *dateString = [self getStringFromDate:[self dayOnlyDateFromDate:date]];
    NSString *dateSelectedString = [self  getStringFromDate:[self dayOnlyDateFromDate:date2]];
    
    if ([dateString  isEqualToString:dateSelectedString]){
        
        return true;
    }
    else
        return false;
}




#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        
        return [[[APP_DELEGATE notesFetchController]fetchedObjects]count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    NoteCell* noteCell = [self.tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        aNote = [searchResults objectAtIndex:indexPath.row];
    } else {
        aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    }
    
    
    [noteCell configureNoteCellWithNote:aNote];
    return noteCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
   
    NSAttributedString *myAttrString =
    [NSKeyedUnarchiver unarchiveObjectWithData: aNote.noteDescription];
    
    NSString* description = myAttrString.string;
    return 46 + [description heightForString];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moveToDiaryButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Diary" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                        {
                                            
                                            NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
                                            [cell setEditing:NO animated:YES];
                                            
                                            Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
                                        
                                            
                                            [APP_DELEGATE moveNoteToDiary:aNote];
                                            NSLog(@"move to Diary");
                                        }];
    
    moveToDiaryButton.backgroundColor =[UIColor grayColor];
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              UIAlertController *alert= [UIAlertController
                                                                         alertControllerWithTitle:@"Delete note"
                                                                         message:@"Do you relly to delete note?"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                              
                                              UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault
                                                                                         handler:^(UIAlertAction * action){
                                                                                           
                                                                                             NSLog(@"Deleting");
                                                                                             
                                                                                             NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
                                                                                             [cell setEditing:NO animated:YES];
                                                                                             
                                                                                             
                                                                                            Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
                                                                                             
                                                                                             [APP_DELEGATE removeNote:aNote];
                                                                                             
                                                                
                                                                                             
                                                                                          
                                                                                         }];
                                              UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                                             handler:^(UIAlertAction * action) {
                                                                                                 
                                                                                                 NSLog(@"cancel btn");
                                                                                                 
                                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                 
                                                                                             }];
                                              
                                              [alert addAction:delete];
                                              [alert addAction:cancel];
                                              
                                              
                                              [self presentViewController:alert animated:YES completion:nil];

                                          }];
    
     NSArray* buttons = @[deleteButton, moveToDiaryButton];
     return buttons;
}

#pragma mark - NSFetchResultControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controlle
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  //  UITableView *tableView = self.tableView;
    
    UITableView *tableView = controller == [APP_DELEGATE notesFetchController] ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [APP_DELEGATE saveContext];
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

#pragma mark - SearchImppementation

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSLog(@"%@",[evaluatedObject class]);
        
        
        Note* note = evaluatedObject;
            
        NSAttributedString *myAttrString =
            [NSKeyedUnarchiver unarchiveObjectWithData: note.noteDescription];

        if ([myAttrString.string.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound)
        {
            return YES;
        }
        return NO;

       
    }];
    
    searchResults = [[[APP_DELEGATE notesFetchController]fetchedObjects]filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - LTHPasscodeViewDelegate

- (IBAction)diaryPassCodeButtonPressed:(id)sender {
    [[LTHPasscodeViewController sharedUser]setDelegate:self];
    [LTHPasscodeViewController sharedUser].maxNumberOfAllowedFailedAttempts = 3;
    
    [LTHPasscodeViewController useKeychain:YES];
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        if ([LTHPasscodeViewController didPasscodeTimerEnd])
            
            
            [[LTHPasscodeViewController sharedUser]showLockScreenWithAnimation:YES
                                                                    withLogout:YES
                                                                andLogoutTitle:@"Cancel"];
    }else{
        [[LTHPasscodeViewController sharedUser]showForEnablingPasscodeInViewController:self asModal:YES];
    }
    
    
}


- (void)passcodeWasEnteredSuccessfully
{
    
    [self performSegueWithIdentifier:diarySegue sender:self];
    
}
- (void)logoutButtonWasPressed
{
    [LTHPasscodeViewController close];
}

- (void)savePasscode:(NSString *)passcode
{
    
}


- (void)maxNumberOfFailedAttemptsReached {
    [LTHPasscodeViewController close];
    NSLog(@"Max Number of Failed Attemps Reached");
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:cellSegue]) {
        if ([[segue destinationViewController]isKindOfClass:[NoteDesciriptionController class]]) {
            
            NoteDesciriptionController *destination = (NoteDesciriptionController*)[segue destinationViewController];
            destination.isNew = NO;
            NSIndexPath* index = nil;
                        
            if (self.searchDisplayController.active) {
                index = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                destination.note = [searchResults objectAtIndex:index.row];
            } else {
                index = [self.tableView indexPathForSelectedRow];
                 destination.note = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:index.row];
            }
            
        }
    }else if ([[segue identifier]isEqualToString:addSegue]){
        if ([[segue destinationViewController]isKindOfClass:[NoteDesciriptionController class]]) {
            NoteDesciriptionController *destination = (NoteDesciriptionController*)[segue destinationViewController];
            destination.isNew = YES;
        }
    }
    
    if ([[segue identifier]isEqualToString:diarySegue]){
        if([[segue destinationViewController]isKindOfClass:[DiaryTableViewController class]]) {
            DiaryTableViewController *destination = (DiaryTableViewController*)[segue destinationViewController];
        }
    }
}


@end

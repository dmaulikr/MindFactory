//
//  DiaryTableViewController.m
//  MindFactory
//
//  Created by sasha on 26.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "DiaryTableViewController.h"
#import "AppDelegate.h"
#import "DiaryCell.h"
#import "NSString+Heigh.h"
#import "NSDate+GetDay.h"
#import "DiaryDescriptionController.h"
#import "LTHPasscodeViewController.h"

@interface DiaryTableViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, LTHPasscodeViewControllerDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation DiaryTableViewController
{
    
    NSArray *searchResults;
}

@synthesize tableView = _tableView;





- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethod) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)myMethod
{
   
    
    if ([LTHPasscodeViewController doesPasscodeExist]) {
      [[LTHPasscodeViewController sharedUser]showLockScreenWithAnimation:YES
                                                              withLogout:NO
                                                           andLogoutTitle:@"Cancel"];
    }
}
/*
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}*/


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[APP_DELEGATE diaryFetchController] setDelegate: self];
    
    [[LTHPasscodeViewController sharedUser]setDelegate:nil];
  
    //research
    self.searchDisplayController.searchBar.text =  self.searchDisplayController.searchBar.text;
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[APP_DELEGATE diaryFetchController] setDelegate: nil];
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
     [super viewDidAppear:animated];
   
    // reload table
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
       
        [[LTHPasscodeViewController sharedUser] disablePasscodeWhenApplicationEntersBackground];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        NSLog(@"Back pressed");
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath: %ld", (long)indexPath.row);
    
    Diary* aDiary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    DiaryCell* diaryCell = [self.tableView dequeueReusableCellWithIdentifier:@"diaryCell" forIndexPath:indexPath]; 
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        aDiary = [searchResults objectAtIndex:indexPath.row];
    } else {
        aDiary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    }
    
    
    [diaryCell configureDiaryCellWithDiary:aDiary];
    return diaryCell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        
        return [[[APP_DELEGATE diaryFetchController]fetchedObjects]count];
    }
}

#pragma mrak - SwipeToDelete
/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DiaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diaryCell" forIndexPath:indexPath];
        [cell setEditing:NO animated:YES];
        
        NSManagedObject *diary = [[APP_DELEGATE diaryFetchController] objectAtIndexPath:indexPath];
        
         [APP_DELEGATE removeDiary:diary];
    }

}*/

#pragma mark - NSFetchResultControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
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
        
        
        Diary* diary = evaluatedObject;
        
        NSString *dateString = [NSDate getDateStringWithDate:diary.timeStamp];
    
        
        if (([dateString.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound))
        {
            return YES;
        }
        return NO;
        
        
    }];
    
    searchResults = [[[APP_DELEGATE diaryFetchController]fetchedObjects]filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - PassCodeTurnOffAndCgange

- (IBAction)passwordButtonPressed:(id)sender
{

    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select action"
                                                                   message:@"Password"
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *changePassword = [UIAlertAction actionWithTitle:@"Change password"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                        
                                                            [[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController:self asModal:YES];
                                                     
                                                              
                                                          }]; // 2
    UIAlertAction *turnOff = [UIAlertAction actionWithTitle:@"Turn Off"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                        
                                                               [[LTHPasscodeViewController sharedUser] showForDisablingPasscodeInViewController:self
                                                                                                                                        asModal:YES];
                                                               
                                                           }];
    
    UIAlertAction *turnOn = [UIAlertAction actionWithTitle:@"Turn On"
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                        
                                                          [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self
                                                                                                                                  asModal:YES];
                                                      }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                               
                                                           }]; // 3
    
    
    
    
    
    bool a = [LTHPasscodeViewController doesPasscodeExist];
    if (a) {
        [alert addAction:changePassword]; // 4
        [alert addAction:turnOff]; // 5
    } else {
        [alert addAction:turnOn];
    }
    
    [alert addAction:cancelAction];
    
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
    

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"editSegue"]) {
        if ([[segue destinationViewController]isKindOfClass:[DiaryDescriptionController class]])
        {
            DiaryDescriptionController *destination = (DiaryDescriptionController *)[segue destinationViewController];
            NSIndexPath* index = nil;
            
            if (self.searchDisplayController.active) {
                index = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                destination.diary = [searchResults objectAtIndex:index.row];
            } else {
                index = [self.tableView indexPathForSelectedRow];
                destination.diary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:index.row];
            }
            
        }
    }
    
}


@end

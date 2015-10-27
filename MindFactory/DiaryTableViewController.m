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

@interface DiaryTableViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation DiaryTableViewController
{
    
    NSArray *searchResults;
}

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
      [[APP_DELEGATE diaryFetchController] setDelegate: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - AddNewDiary

- (IBAction)addButtonPressed:(id)sender {
    
}


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
        
        NSAttributedString *myAttrString =
        [NSKeyedUnarchiver unarchiveObjectWithData: diary.noteDescription];
        
        if ([myAttrString.string rangeOfString:searchText].location != NSNotFound)
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

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
#import "DiaryDescriptionController.h"

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

    [[APP_DELEGATE diaryFetchController] setDelegate: self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Diary* aDiary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    
    NSAttributedString *myAttrString =
    [NSKeyedUnarchiver unarchiveObjectWithData: aDiary.noteDescription];
    
    NSString* description = myAttrString.string;
    return 46 + [description heightForString];
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

#pragma mrak - SwipeToDelete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DiaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diaryCell" forIndexPath:indexPath];
        [cell setEditing:NO animated:YES];
        
        NSManagedObject *diary = [[APP_DELEGATE diaryFetchController] objectAtIndexPath:indexPath];
        
         [APP_DELEGATE removeDiary:diary];
    }

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
        
        if ([myAttrString.string.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound)
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



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"editSegue"]) {
        if ([[segue destinationViewController]isKindOfClass:[DiaryDescriptionController class]])
        {
            DiaryDescriptionController *destination = (DiaryDescriptionController *)[segue destinationViewController];
            
            destination.isNew = NO;
            NSIndexPath* index = nil;
            
            if (self.searchDisplayController.active) {
                index = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                destination.diary = [searchResults objectAtIndex:index.row];
            } else {
                index = [self.tableView indexPathForSelectedRow];
                destination.diary = [[[APP_DELEGATE diaryFetchController]fetchedObjects]objectAtIndex:index.row];
            }
            
        }
    }else if ([[segue identifier]isEqualToString:@"addSegue"]){
        if ([[segue destinationViewController]isKindOfClass:[DiaryDescriptionController class]]) {
            DiaryDescriptionController *destination = (DiaryDescriptionController *)[segue destinationViewController];
            destination.isNew = YES;
        }
    }

    
    
}


@end

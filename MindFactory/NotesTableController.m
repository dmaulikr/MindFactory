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

#define cellSegue @"cellSegue"
#define addSegue @"addSegue"


@interface NotesTableController ()
<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotesTableController
{

    NSArray *searchResults;
}

@synthesize tableView = _tableView;


- (void)viewDidLoad {
    [super viewDidLoad];
    [[APP_DELEGATE notesFetchController] setDelegate: self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
// Swipe to delete.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
   
    NSAttributedString *myAttrString =
    [NSKeyedUnarchiver unarchiveObjectWithData: aNote.noteDescription];
    
    NSString* description = myAttrString.string;
    return 46 + [description heightForString];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *note = [[APP_DELEGATE notesFetchController] objectAtIndexPath:indexPath];
        [APP_DELEGATE removeNote:note];
//        [tableView reloadData];
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
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

        if ([myAttrString.string rangeOfString:searchText].location != NSNotFound)
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:cellSegue]) {
        if ([[segue destinationViewController]isKindOfClass:[NoteDesciriptionController class]]) {
            NoteDesciriptionController *destination = (NoteDesciriptionController*)[segue destinationViewController];
            destination.isNew = NO;
            NSIndexPath* index = nil;
            if ([sender isKindOfClass:[UITableViewCell class]]) {
                index = [self.tableView indexPathForCell:sender];
            }
            if (index) {
                destination.note = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:index.row];
            }
        }
    }else if ([[segue identifier]isEqualToString:addSegue]){
        if ([[segue destinationViewController]isKindOfClass:[NoteDesciriptionController class]]) {
            NoteDesciriptionController *destination = (NoteDesciriptionController*)[segue destinationViewController];
            destination.isNew = YES;
        }
    }
}


@end

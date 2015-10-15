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
#import "NSString+Heigh.h"
#import "AppDelegate.h"

#define cellSegue @"cellSegue"
#define addSegue @"addSegue"
//#define APP (AppDelegate*)[[UIApplication sharedApplication]delegate]

@interface NotesTableController ()
<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotesTableController

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[APP_DELEGATE notesFetchController] setDelegate: self];
    // Do any additional setup after loading the view.
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

#pragma - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[APP_DELEGATE notesFetchController]fetchedObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    NoteCell* noteCell = [self.tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
    [noteCell configureNoteCellWithNote:aNote];
    return noteCell;
}

#pragma mark - UITableViewDelegate
// Swipe to delete.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note* aNote = [[[APP_DELEGATE notesFetchController]fetchedObjects]objectAtIndex:indexPath.row];
    NSString* description = aNote.noteDescription;
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

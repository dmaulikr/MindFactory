//
//  MoneyViewController.m
//  Money
//
//  Created by sasha on 22.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "MoneyViewController.h"
#import "AddMoneyViewController.h"
#import "TodoCell.h"



@interface MoneyViewController ()


//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[APP_DELEGATE fetchedResultsController]setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[[APP_DELEGATE fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ToDoCell";
    
    TodoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Item *info = [[APP_DELEGATE fetchedResultsController] objectAtIndexPath:indexPath];
    [cell configureCellWithMoneyInfo:info];
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - DELETE

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *info = [[APP_DELEGATE fetchedResultsController] objectAtIndexPath:indexPath];
    [APP_DELEGATE deleteItem:info];
    NSLog(@"Row deleted");
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Edit seque money
    if ([segue.identifier isEqualToString:@"EditSegueMoney"]) {
        if ([[segue destinationViewController]isKindOfClass:[AddMoneyViewController class]]) {
            AddMoneyViewController* destination = [segue destinationViewController];
            destination.isNew = NO;
            
            //
            if([sender isKindOfClass:[UITableViewCell class]]) {
                NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
               // NSLog(@"Selected row: %ld", (long)indexPath.row);
                Item *info = [[APP_DELEGATE fetchedResultsController] objectAtIndexPath:indexPath];
                destination.item = info;
            }
            //
        
            
            NSLog(@"EDIT!!!");
        }
    }
    //Add button pressed
    if ([segue.identifier isEqualToString:@"AddSegueMoney"]) {
            if ([[segue destinationViewController]isKindOfClass:[AddMoneyViewController class]]) {
                AddMoneyViewController* destination = [segue destinationViewController];
                destination.isNew = YES;
                destination.isPositive = YES;
            
                NSLog(@"Add!!");
            }
    }

    //Sub button pressed
    if ([segue.identifier isEqualToString:@"SubSegueMoney"])
    {
            if ([[segue destinationViewController]isKindOfClass:[AddMoneyViewController class]]) {
                AddMoneyViewController* destination = [segue destinationViewController];
                destination.isNew = YES;
                destination.isPositive = NO;
                
                NSLog(@"Sub!!");
            }
    }

    
}
@end


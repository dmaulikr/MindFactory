//
//  DiaryViewController.m
//  MindFactory
//
//  Created by sasha on 23.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "DiaryViewController.h"


@interface DiaryViewController ()
{
    //PasscodeViewController
    LTHPasscodeViewController *_passcodeController;
}

@end

@implementation DiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[LTHPasscodeViewController sharedUser]setDelegate:self];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)passcodeViewControllerWillClose
{
    
}
- (void)maxNumberOfFailedAttemptsReached
{
    
}
- (void)passcodeWasEnteredSuccessfully
{
    
}
- (void)logoutButtonWasPressed
{
    [LTHPasscodeViewController close];
 //   [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deletePasscode
{
    
}
- (void)savePasscode:(NSString *)passcode
{
    
}

/*#pragma mark - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}*/




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

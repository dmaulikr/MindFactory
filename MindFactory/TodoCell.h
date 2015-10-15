//
//  TodoCell.h
//  Money
//
//  Created by sasha on 23.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface TodoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonBtn;


- (void)configureCellWithMoneyInfo:(Item*)info;

@end

//
//  NoteCell.h
//  Diary
//
//  Created by Mac on 14.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NoteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)configureNoteCellWithNote:(Note*)note;

@end

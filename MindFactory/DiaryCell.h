//
//  DiaryCell.h
//  MindFactory
//
//  Created by sasha on 27.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DiaryCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


- (void)configureDiaryCellWithDiary:(Diary *)diary;

@end

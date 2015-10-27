//
//  DiaryCell.m
//  MindFactory
//
//  Created by sasha on 27.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "DiaryCell.h"

@implementation DiaryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureDiaryCellWithDiary:(Diary *)diary
{
    // self.titleLabel.text = note.title;
    NSAttributedString *myAttrString =
    [NSKeyedUnarchiver unarchiveObjectWithData: diary.noteDescription];
    
    //  NSString* description = ;
    self.descriptionLabel.text = myAttrString.string;
    
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    
    // [dateformate setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    [dateformate setDateFormat:@"EEE MMM d HH:mm"];
    
    
    
    NSString *date = [dateformate stringFromDate:diary.timeStamp]; // Convert date to string
    NSLog(@"diary date :%@",date);
    self.dateLabel.text = date;
}

@end

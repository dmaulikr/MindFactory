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

- (NSString *)getDateStringWithDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:kCFDateFormatterShortStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)getDayStringWithDate:(NSDate *)now
{
  //  NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    return [dateFormatter stringFromDate:now];
}



- (void)configureDiaryCellWithDiary:(Diary *)diary
{
    // self.titleLabel.text = note.title;
    NSAttributedString *myAttrString =
    [NSKeyedUnarchiver unarchiveObjectWithData: diary.noteDescription];
     
    //
    
    NSString *dateString = [self getDateStringWithDate:diary.timeStamp];
    NSString *dayString = [self getDayStringWithDate:diary.timeStamp];
    
    self.dayLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", dateString, dayString];
    self.descriptionLabel.text = @"Mega day";
}

@end

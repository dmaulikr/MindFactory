//
//  DiaryCell.m
//  MindFactory
//
//  Created by sasha on 27.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "DiaryCell.h"
#import "NSDate+GetDay.h"


@implementation DiaryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
    // Configure the view for the selected state
}


#pragma mark - ConfigureCellOfDiary
- (void)configureDiaryCellWithDiary:(Diary *)diary
{    
    NSString *dateString = [NSDate getDateStringWithDate:diary.timeStamp];
    
    
    NSInteger index = [diary.indexSmile integerValue];
    NSArray *smileArray = [[NSArray alloc]initWithObjects:@"😡", @"😒", @"😊", @"😃", @"😍", nil];
    
    self.dayLabel.text = dateString;
    self.descriptionLabel.text = [smileArray objectAtIndex:index];
}

@end

//
//  NoteCell.m
//  Diary
//
//  Created by Mac on 14.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import "NoteCell.h"
#import "NSString+Heigh.h"

@implementation NoteCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureNoteCellWithNote:(Note*)note
{
   // self.titleLabel.text = note.title;
    NSAttributedString *myAttrString =
    [NSKeyedUnarchiver unarchiveObjectWithData: note.noteDescription];
    
  //  NSString* description = ;
    self.descriptionLabel.text = myAttrString.string;
}

@end

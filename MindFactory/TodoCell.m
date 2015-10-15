//
//  TodoCell.m
//  Money
//
//  Created by sasha on 23.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "TodoCell.h"


@implementation TodoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithMoneyInfo:(Item*)info {
    NSString *str = [[NSString alloc]initWithFormat:@"%@", info.value];
   
    if ([info.positive intValue] == 1) {
        self.nameLabel.textColor = [UIColor greenColor];
        self.nameLabel.text = [[NSString alloc]initWithFormat:@"+%@", str];
    } else {
        self.nameLabel.textColor = [UIColor redColor];
        self.nameLabel.text = [[NSString alloc]initWithFormat:@"-%@", str];
    }
}


@end

//
//  NSString+Heigh.m
//  Diary
//
//  Created by Mac on 14.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Heigh.h"
#import "AppDelegate.h"
#define APP (AppDelegate*)[[UIApplication sharedApplication]delegate]


@implementation NSString (Heigh)

static const float maxHeight = 30;
static const float offset = 16;
static const float fontSize = 14;


- (CGFloat)heightForString
{
    CGFloat theWidth = [APP window].screen.bounds.size.width;
    UIFont *aFont = [UIFont systemFontOfSize:fontSize];
    CGSize maximumLabelSize = CGSizeMake(theWidth - offset,maxHeight);
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:aFont
                                                                forKey:NSFontAttributeName];
    NSAttributedString *atrString = [[NSAttributedString alloc]initWithString:self attributes:attrsDictionary];
    
    CGRect stringRect = [atrString boundingRectWithSize:maximumLabelSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    return stringRect.size.height;
}

@end

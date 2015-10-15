//
//  UIImage+UIImage_Additional.m
//  Money
//
//  Created by sasha on 12.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "UIImage+UIImage_Additional.h"

@implementation UIImage (UIImage_Additional)

+ (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

@end

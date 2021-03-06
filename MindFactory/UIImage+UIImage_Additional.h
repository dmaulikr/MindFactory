//
//  UIImage+UIImage_Additional.h
//  Money
//
//  Created by sasha on 12.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Additional)

+ (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)resizeImageToFitWidth:(CGFloat)resizedWidth;


@end

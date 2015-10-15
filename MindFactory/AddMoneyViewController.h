//
//  AddMoneyViewController.h
//  Money
//
//  Created by sasha on 24.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import <TesseractOCR/TesseractOCR.h>


@interface AddMoneyViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
//it's new Object?
@property(nonatomic) BOOL isNew;
//it's edit Row Item
@property(strong, nonatomic) Item* item;
//is's Positive or Negative
@property(nonatomic) BOOL isPositive;
//imageToRecognize
@property (strong, nonatomic) IBOutlet UIImage *imageToRecognize;


@end

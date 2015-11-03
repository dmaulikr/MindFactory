//
//  DiaryDescriptionController.m
//  MindFactory
//
//  Created by sasha on 27.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "DiaryDescriptionController.h"
#import <iOS-Color-Picker/FCColorPickerViewController.h>

@interface DiaryDescriptionController () <FCColorPickerViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate>


@property (nonatomic, copy) UIColor *color;


@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addDiaryButton;

@property (strong, nonatomic) NSMutableAttributedString *attrString;



//selected string
@property NSInteger startStr;
@property NSInteger endStr;

@end

@implementation DiaryDescriptionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.descriptionTextField setScrollEnabled:YES];
 
    self.addDiaryButton.title = @"Save";
    
    if (self.diary) {
        
        NSAttributedString *myAttrString =
        [NSKeyedUnarchiver unarchiveObjectWithData: self.diary.noteDescription];
        
        self.descriptionTextField.attributedText = myAttrString;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AddNewDiary

- (IBAction)addOrSaveButtonPressed:(id)sender {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.descriptionTextField.attributedText];
    self.diary.noteDescription = data;
    self.diary.timeStamp = [NSDate date];
    [APP_DELEGATE saveContext];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Text Delegates

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    
    NSRange r = self.descriptionTextField.selectedRange;
    NSLog(@"Start from : %lu",(unsigned long)r.location); //starting selection in text selection
    NSLog(@"To : %lu",(unsigned long)r.length); // end position in text selection
    NSLog([self.descriptionTextField.text substringWithRange:NSMakeRange(r.location, r.length)]); //tv is my text view
    
    
    if ( (r.length != 0)) {
        self.startStr = r.location;
        self.endStr = r.length;
    }
    
    
    
     NSLog(@"%ld:%ld", (long)self.startStr, (long)self.endStr);
}

#pragma mark - Color Picker
- (IBAction)pickColorButtonPressed:(id)sender {
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPickerWithColor:self.color
                                                                                        delegate:self];
    colorPicker.tintColor = [UIColor blackColor];
    colorPicker.backgroundColor = [UIColor whiteColor];
    colorPicker.color = [UIColor redColor];
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker
                       animated:YES
                     completion:nil];

}

#pragma mark - FCColorPickerViewControllerDelegate Methods

- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker
                   didSelectColor:(UIColor *)color
{
    self.color = color;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setColor:(UIColor *)color
{
    _color = [color copy];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
       
    
    
    NSLog(@"%ld:%ld", (long)self.startStr, (long)self.endStr);
    
    [string addAttribute:NSForegroundColorAttributeName value:_color range:NSMakeRange(self.startStr, self.endStr)];

    
    
   // }
        self.descriptionTextField.attributedText = string;

    
    self.startStr = 0;
    self.endStr = 0;
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

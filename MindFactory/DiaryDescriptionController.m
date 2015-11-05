//
//  DiaryDescriptionController.m
//  MindFactory
//
//  Created by sasha on 27.10.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "DiaryDescriptionController.h"
#import <iOS-Color-Picker/FCColorPickerViewController.h>
#import "UIImage+UIImage_Additional.h"

@interface DiaryDescriptionController () <FCColorPickerViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate>
{
    NSInteger indexSmile;
    CGFloat fontSize;
}


@property (nonatomic, copy) UIColor *color;
//picker for photo
@property (strong, nonatomic) UIImagePickerController *pickerForPhoto;


//stepper font size
@property (weak, nonatomic) IBOutlet UIStepper *stepperOutlet;




@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addDiaryButton;

@property (strong, nonatomic) NSMutableAttributedString *attrString;


//smileRaiting view
@property (weak, nonatomic) IBOutlet UIControl *madSmileView;
@property (weak, nonatomic) IBOutlet UIControl *sadSmileView;
@property (weak, nonatomic) IBOutlet UIControl *smileSmileView;
@property (weak, nonatomic) IBOutlet UIControl *loveSmileView;
@property (weak, nonatomic) IBOutlet UIControl *happySmileView;
//end

//constant
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomSpace;
//end

//selected string
@property NSInteger startStr;
@property NSInteger endStr;
//end
@end

@implementation DiaryDescriptionController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.descriptionTextField setScrollEnabled:YES];
 
    self.addDiaryButton.title = @"Save";
    
    if (self.diary) {
        
        NSAttributedString *myAttrString =
        [NSKeyedUnarchiver unarchiveObjectWithData: self.diary.noteDescription];
        
        self.descriptionTextField.attributedText = myAttrString;
        
        //load smileView
        [self loadSmileView];
    }
    self.startStr = 0;
    self.endStr = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewUpToShowKeyboard
- (void)keyboardDidShow: (NSNotification *) notif{
    // Do something here
    self.scrollViewBottomSpace.constant = 253;
    [self.view layoutIfNeeded];
    
    
    //set UITextView scrolling
    UITextRange *range = self.descriptionTextField.selectedTextRange;
    UITextPosition *position = range.start;
    CGRect cursorRect = [self.descriptionTextField caretRectForPosition:position];
    CGPoint cursorPoint = CGPointMake(0, cursorRect.origin.y);
    
    CGFloat contentFix = cursorPoint.y - self.descriptionTextField.frame.size.height + 25;
    
    if (contentFix < 0) {
        contentFix = 0;
    }
    
    [self.descriptionTextField setContentOffset:CGPointMake((cursorPoint.x ) * 1, contentFix * 1) animated:YES];
    
    //when keyboard hide uitextView
    //end
    //constant
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
}



#pragma mark - AddNewDiary

- (IBAction)addOrSaveButtonPressed:(id)sender {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.descriptionTextField.attributedText];
    self.diary.noteDescription = data;   
    
    NSNumber *index = [NSNumber numberWithInteger: indexSmile];
    self.diary.indexSmile = index;
    [APP_DELEGATE saveContext];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Text Delegates
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSRange r = self.descriptionTextField.selectedRange;
    NSLog(@"Start from : %lu",(unsigned long)r.location); //starting selection in text selection
    NSLog(@"To : %lu",(unsigned long)r.length); // end position in text selection
    NSString *tmp = [self.descriptionTextField.text substringWithRange:NSMakeRange(r.location, r.length)];
    NSLog(@"%@", tmp); //tv is my text view
    
    self.startStr = r.location;
    self.endStr = r.length;
    
    // NSString *fontName = self.descriptionTextField.font.fontName;
    fontSize = self.descriptionTextField.font.pointSize;
    
    self.stepperOutlet.value = fontSize;
    

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
    
    self.descriptionTextField.attributedText = string;

    
    self.startStr = 0;
    self.endStr = 0;
    
}

#pragma mark - UISmileViewAction
-(void)loadSmileView
{
    indexSmile = [self.diary.indexSmile integerValue];
    [self clearBackgroundSmileView];
    
    switch (indexSmile) {
        case 0:
            self.madSmileView.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            self.sadSmileView.backgroundColor = [UIColor blueColor];
            break;
        case 2:
            self.smileSmileView.backgroundColor = [UIColor blueColor];
            break;
        case 3:
            self.happySmileView.backgroundColor = [UIColor blueColor];
            break;
        case 4:
            self.loveSmileView.backgroundColor = [UIColor blueColor];
            break;
    }
}


-(void)clearBackgroundSmileView
{
    self.madSmileView.backgroundColor = [UIColor yellowColor];
    self.happySmileView.backgroundColor = [UIColor yellowColor];
    self.loveSmileView.backgroundColor = [UIColor yellowColor];
    self.sadSmileView.backgroundColor = [UIColor yellowColor];
    self.smileSmileView.backgroundColor = [UIColor yellowColor];
}


- (IBAction)happySmileViewTouch:(id)sender
{
    [self clearBackgroundSmileView];
    
    self.happySmileView.backgroundColor = [UIColor blueColor];
    indexSmile = 3;
}

- (IBAction)madSmileViewTouch:(id)sender
{
    [self clearBackgroundSmileView];
    
    self.madSmileView.backgroundColor = [UIColor blueColor];
    indexSmile = 0;
}

- (IBAction)loveSmileViewTouch:(id)sender
{
    [self clearBackgroundSmileView];
    
    self.loveSmileView.backgroundColor = [UIColor blueColor];
    indexSmile = 4;
}

- (IBAction)sadSmileViewTouch:(id)sender
{
    [self clearBackgroundSmileView];
    
    self.sadSmileView.backgroundColor = [UIColor blueColor];
    indexSmile = 1;
}

- (IBAction)smileSmileViewTouch:(id)sender {
    [self clearBackgroundSmileView];
    
    self.smileSmileView.backgroundColor = [UIColor blueColor];
    indexSmile = 2;
}

#pragma mark - PhotoToTextView

- (IBAction)addPhotoToTextView:(id)sender {
    [[self view] endEditing:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select action"
                                                                   message:@"Select a photo?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Camera"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              
                                                                [self photoFromCamera];
                                                              
                                                          }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Gallery"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               
                                                               [self photoFromGallary];
                                                               
                                                           }]; // 3

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                               
                                                           }]; // 3
    
    
    
    [alert addAction:firstAction]; // 4
    [alert addAction:secondAction]; // 5
    [alert addAction:cancelAction];
    
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
}

- (void)photoFromCamera
{
    self.pickerForPhoto = [[UIImagePickerController alloc] init];
    self.pickerForPhoto.delegate = self;
    self.pickerForPhoto.allowsEditing = YES;
    self.pickerForPhoto.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.pickerForPhoto animated:YES completion:NULL];
}

- (void)photoFromGallary
{
    self.pickerForPhoto = [[UIImagePickerController alloc] init];
    self.pickerForPhoto.delegate = self;
    self.pickerForPhoto.allowsEditing = YES;
    self.pickerForPhoto.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.pickerForPhoto animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
   
    
    CGSize newSize;
    newSize.height = 90;
    newSize.width = 120;
    
    chosenImage = [UIImage imageWithImage:chosenImage scaledToSize:newSize];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = chosenImage;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(self.startStr, self.endStr) withAttributedString:attrStringWithImage];

    //fixing to font to 16
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    
    [attributedString addAttributes:attrsDictionary range:NSMakeRange(self.endStr, self.endStr)];
    //endfix
    
    self.descriptionTextField.attributedText = attributedString;
    
    //end
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark - StepperSizeFont
- (IBAction)stepperClickAction:(id)sender {
    
    if ( (self.startStr == 0) && (self.endStr == 0) )
    {
        return;
    }
    
    NSString *fontName = self.descriptionTextField.font.fontName;
    
    
    //fixing to font to 16
    UIFont *font = [UIFont fontWithName:fontName size:self.stepperOutlet.value];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
    
    [string addAttributes:attrsDictionary range:NSMakeRange(self.startStr, self.endStr)];
    
    NSLog(@"%ld : %ld", (long)self.startStr, (long)self.endStr);
    
    NSInteger start = self.startStr;
    NSInteger end = self.endStr;
    
    
    self.descriptionTextField.attributedText = string;
    //endfix
    
    NSLog(@"Stepper value: %f", self.stepperOutlet.value);
    
   // [self.descriptionTextField select:self];
    [self.descriptionTextField becomeFirstResponder];
    self.descriptionTextField.selectedRange = NSMakeRange(start, end);
   
    self.startStr = start;
    self.endStr = end;
}

#pragma mark - BoldAndItallicText

- (IBAction)italicButtonPressed:(id)sender
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
    
    if (self.endStr != 0) {
        [self.descriptionTextField becomeFirstResponder];
        [string addAttribute:NSFontAttributeName
                       value:[UIFont italicSystemFontOfSize:fontSize]
                       range:NSMakeRange(self.startStr, self.endStr)];
        
        
        NSInteger start = self.startStr;
        self.descriptionTextField.attributedText = string;
        [self.descriptionTextField becomeFirstResponder];
        self.descriptionTextField.selectedRange = NSMakeRange(start, 0);
    }
    
}

- (IBAction)boldButtonPressed:(id)sender
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
    
    if (self.endStr != 0) {
        [string addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:fontSize]
                       range:NSMakeRange(self.startStr, self.endStr)];
        
        
        
        NSInteger start = self.startStr;
        
        self.descriptionTextField.attributedText = string;
        [self.descriptionTextField becomeFirstResponder];
        self.descriptionTextField.selectedRange = NSMakeRange(start, 0);
    }
}



@end

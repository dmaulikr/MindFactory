//
//  NoteDesciriptionController.m
//  Diary
//
//  Created by Mac on 08.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import "NoteDesciriptionController.h"
#import "NoteCell.h"

#define segueString @"modalConfirm"

@interface NoteDesciriptionController ()
<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomSpace;

@property (strong, nonatomic) NSMutableAttributedString *attrString;

//selected string
@property NSInteger startStr;
@property NSInteger endStr;

@end

@implementation NoteDesciriptionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   [self.descriptionTextField setScrollEnabled:YES];
    if (self.isNew) {
        self.addButton.title = @"Add";
    }else{
        self.addButton.title = @"Save";
    }
    if (self.note) {
        
        NSAttributedString *myAttrString =
        [NSKeyedUnarchiver unarchiveObjectWithData: self.note.noteDescription];
    
        self.descriptionTextField.attributedText = myAttrString;
        NSLog(@"%@", myAttrString);
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

}


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


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [UIView commitAnimations];
        return NO;
    }
    return YES;
}

- (IBAction)backgrountTapAction:(id)sender
{
    if ([self.descriptionTextField isFirstResponder]) {
        [self.descriptionTextField resignFirstResponder];
        
    }
    self.scrollViewBottomSpace.constant = 0;
    [self.view layoutSubviews];
}

- (IBAction)addButtonAction:(id)sender
{
    if (self.isNew) {
         NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.descriptionTextField.attributedText];
        [APP_DELEGATE addNewNoteWithText:data];
    }else{
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.descriptionTextField.attributedText];
        self.note.noteDescription = data;
        self.note.timeStamp = [NSDate date];
        [APP_DELEGATE saveContext];
    }
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Editing

- (void)textViewDidBeginEditing:(UITextView *)textView
{

}


#pragma mark - Text Delegates

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSRange r = self.descriptionTextField.selectedRange;
    NSLog(@"Start from : %lu",(unsigned long)r.location); //starting selection in text selection
    NSLog(@"To : %lu",(unsigned long)r.length); // end position in text selection
    NSLog([self.descriptionTextField.text substringWithRange:NSMakeRange(r.location, r.length)]); //tv is my text view
   
    self.startStr = r.location;
    self.endStr = r.length;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AttributedString

- (IBAction)italicText:(id)sender {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
    
 
    
    NSString *fontName = self.descriptionTextField.font.fontName;
    CGFloat fontSize = self.descriptionTextField.font.pointSize;
    
    if (self.endStr != 0) {
        [string addAttribute:NSFontAttributeName
                       value:[UIFont italicSystemFontOfSize:18]
                       range:NSMakeRange(self.startStr, self.endStr)];
        
        
        self.descriptionTextField.attributedText = string;
        
    }
}


- (IBAction)boldText:(id)sender {
   
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:self.descriptionTextField.attributedText];
    
    NSString *fontName = self.descriptionTextField.font.fontName;
    CGFloat fontSize = self.descriptionTextField.font.pointSize;
    
    if (self.endStr != 0) {
        [string addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:18]
                             range:NSMakeRange(self.startStr, self.endStr)];
        
     
    
        self.descriptionTextField.attributedText = string;
        
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}
*/

@end

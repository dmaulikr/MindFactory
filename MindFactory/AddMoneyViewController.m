//
//  AddMoneyViewController.m
//  Money
//
//  Created by sasha on 24.09.15.
//  Copyright © 2015 CEIT. All rights reserved.
//

#import "AddMoneyViewController.h"
#import "AppDelegate.h"
#import "UIImage+UIImage_Additional.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"

@interface AddMoneyViewController ()


@property (weak, nonatomic) IBOutlet UIButton *AddOrSaveButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *keyboardButtonSaveAndAdd;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *notePhotoButton;


@property (nonatomic) BOOL isDotPressed;
@property (nonatomic) NSString *beforeDot;
@property (nonatomic) NSString *afterDot;
@property (nonatomic) NSString *sign;
@property (nonatomic) NSInteger countEditing;


//picker for photo
@property (strong, nonatomic) UIImagePickerController *pickerForImage;
//picker for
@property (strong, nonatomic) UIImagePickerController *pickerForRecognizeImage;


@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (strong, nonatomic) M13ProgressHUD *progresViewHUD;

@end

@implementation AddMoneyViewController


- (IBAction)doneButtonPressed:(id)sender {
     [[self view] endEditing:YES];
}


- (void)recognizeUIImageTouch
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePicture)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleTap];
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    //tessteract
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    
    [self recognizeUIImageTouch];

    if (self.isNew == YES) {
        
        [self.AddOrSaveButton setTitle:@"Add" forState:UIControlStateNormal];
        [self.keyboardButtonSaveAndAdd setTitle:@"Add" forState:UIControlStateNormal];
        self.textField.text = @"0.00";
        
        if (self.isPositive) {
            self.sign = @"+";
            
        } else {
            self.sign = @"-";
        }
        
    } else if (self.isNew == NO) {
        
        NSString *buf = [[NSString alloc]initWithFormat:@"%@", self.currentItem.value];
        self.textField.text = buf;
        self.noteTextView.text = self.currentItem.notes;
       
        self.imageView.image = [self imageFromData:self.currentItem.photo];
        
        
        [self.AddOrSaveButton setTitle:@"Save" forState:UIControlStateNormal];
        [self.keyboardButtonSaveAndAdd setTitle:@"Save" forState:UIControlStateNormal];
        
        if ([self.textField.text isEqualToString:@"0"]) {
            self.textField.text = @"0.00";
        }
        
        if (![self.textField.text containsString:@"."]) {
            self.textField.text = [[NSString alloc]initWithFormat:@"%@.00",self.textField.text];
        }
        
        [self splitDotThreeStrings];
        if ([self numberAfterDot] == 1) {
            self.textField.text = [[NSString alloc]initWithFormat:@"%@0",self.textField.text];
        }
        
        NSLog(@"Item positive:   %@", self.currentItem.positive);
        if ([self.currentItem.positive intValue] == 1) {
            self.sign = @"+";
        } else {
            self.sign = @"-";
        }
        NSLog(@"PPPPPP:   %@", self.sign);
        
    }
    
   
    
    self.textField.text = [[NSString alloc]initWithFormat:@"%@%@", self.sign, self.textField.text];
    self.countEditing = 0;
    self.isDotPressed = NO;
   
    
    
    //[self recognizeImageWithTesseract:[UIImage imageNamed:@"checkUKR.jpg"]];

    
    //fixing
    [self loadM13ProgressSuite];
    
}
#pragma mark - ButtonPressed

- (IBAction)addOrSaveItem:(id)sender {
    if (self.isNew == YES) {
        NSDate *now = [NSDate date];
        
        NSString *tmpStr =  [[NSString alloc]initWithFormat:@"%@.%@", self.beforeDot, self.afterDot];
        NSNumber  *value = [NSNumber numberWithFloat: [tmpStr floatValue]];
        
        NSData *photo = [self dataFromImage:self.imageView.image];
        NSNumber *sign;
        
        
        sign = [[NSNumber alloc]initWithBool:self.isPositive];
        
        
        NSLog(@"%@", sign);
        
        
        
        [APP_DELEGATE createNewItem:value andDate:now andNotesDescription:self.noteTextView.text andPhoto:photo numberSign:sign];
    
    } else if (self.isNew == NO) {
        
        NSString *tmpStr =  [[NSString alloc]initWithFormat:@"%@.%@", self.beforeDot, self.afterDot];
        NSNumber  *value = [NSNumber numberWithFloat: [tmpStr floatValue]];
        
        self.currentItem.value = value;
        self.currentItem.timeStamp = [NSDate date];
        self.currentItem.notes = self.noteTextView.text;
        self.currentItem.photo = [self dataFromImage:self.imageView.image];
        
        [APP_DELEGATE saveContext];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)cabcelButtonPresed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CalculatorKeyboardActions


- (BOOL) checkZeroFix
{
    if ([self.beforeDot isEqual:@"0"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)checkStringContainDot:(NSString *)string
{
    if ([string containsString:@"."]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)numberAfterDot
{
    int count = 0;
    for (int i = 0; i < [self.afterDot length]; i++) {
        if (![[self.afterDot substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"0"]) {
            count++;
        }
    }
    return count;
}

- (void)concatenateStrings
{
    self.textField.text = [[NSString alloc]initWithFormat:@"%@%@.%@", self.sign, self.beforeDot, self.afterDot];
}


- (void)splitDotThreeStrings
{
    NSString *tmp = self.textField.text;
  
 
    if ([tmp hasPrefix:@"+"] || [tmp hasPrefix:@"-"]) {
        tmp = [tmp substringFromIndex:1];
    }
    
    
    NSLog(@"%@", tmp);
    
    NSArray *myStrTmp = [tmp componentsSeparatedByString:@"."];
    self.beforeDot = [myStrTmp objectAtIndex:0];
    self.afterDot = [myStrTmp objectAtIndex:1];
}

- (BOOL)isZero:(NSString *)letter
{
    if ([letter isEqualToString:@"0"]) {
        return YES;
    }
    return NO;
}



- (IBAction)keyboardPressed:(UIButton *)sender {
    NSInteger idButton = sender.tag;
    [self splitDotThreeStrings];
    
    if (self.isDotPressed) {
        
        if (self.countEditing == 0) {
            self.afterDot = [[NSString alloc]initWithFormat:@"%ld%@", (long)idButton, [self.afterDot substringWithRange:NSMakeRange(1, 1)]];
            self.countEditing++;
        } else if (self.countEditing == 1) {
                self.afterDot = [[NSString alloc]initWithFormat:@"%@%ld", [self.afterDot substringWithRange:NSMakeRange(0, 1)], (long)idButton];
                self.countEditing++;
            
            
        } else {
             self.isDotPressed = NO;
        }
        
    } else {

        if ([self checkZeroFix]) {
            self.beforeDot = [[NSString alloc]initWithFormat:@"%ld", (long)idButton ];
        } else {
            NSString *number = [NSString stringWithFormat:@"%@%ld", self.beforeDot, (long)idButton];
            self.beforeDot = number;
        }
    }
    
    [self concatenateStrings];
}

- (IBAction)keyboardBackSpacePressed:(UIButton *)sender {
    [self splitDotThreeStrings];
    
    if ((self.isDotPressed) || ([self.beforeDot isEqualToString:@"0"])) {
        
    
        if ([self numberAfterDot] == 0) {
            self.isDotPressed = YES;
            self.countEditing = 0;
        }
        
        if ([self numberAfterDot] == 1) {
            self.afterDot = [[NSString alloc]initWithFormat:@"00"];
            self.countEditing = 0;
        }
        
        if ([self numberAfterDot] == 2) {
            self.afterDot = [[NSString alloc]initWithFormat:@"%@0", [self.afterDot substringWithRange:NSMakeRange(0, 1)]];
            self.countEditing = 1;
        }
     

    } else {
        if ([self.beforeDot length] > 1) {
            self.beforeDot = [self.beforeDot substringToIndex:[self.beforeDot length] - 1];
        } else {
            self.beforeDot = @"0";
        }
    }
    [self concatenateStrings];

}

- (IBAction)keyboardClearButtonPressed:(id)sender {
    self.textField.text = @"0.00";
    self.isDotPressed = NO;
    self.countEditing = 0;
}


- (IBAction)keyboardDotPressed:(id)sender {
    self.isDotPressed = YES;
}

#pragma mark - Camera

-(void)takePicture
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select action"
                                                                   message:@"Select a camera or gallery?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Camera"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self imagePickerFromCamera];
                                                          }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Gallery"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               
                                                               [self imagePickerFromGallary];
                                                               
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



- (void)imagePickerFromCamera
{
    self.pickerForImage = [[UIImagePickerController alloc] init];
    self.pickerForImage.delegate = self;
    self.pickerForImage.allowsEditing = YES;
    self.pickerForImage.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.pickerForImage animated:YES completion:NULL];
}

- (void)imagePickerFromGallary
{
    self.pickerForImage = [[UIImagePickerController alloc] init];
    self.pickerForImage.delegate = self;
    self.pickerForImage.allowsEditing = YES;
    self.pickerForImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.pickerForImage animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    
    if ([picker isEqual:self.pickerForImage]) {
        
        self.imageToRecognize = chosenImage;
        chosenImage = [UIImage compressForUpload:chosenImage scale:0.2];
        self.imageView.image = chosenImage;
    
    } else if ([picker isEqual:self.pickerForRecognizeImage]) {
    
        self.imageToRecognize = chosenImage;
        [self recognizeImageWithTesseract:self.imageToRecognize];

    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark convertDataToUIImage

- (NSData*)dataFromImage:(UIImage*)image
{
    NSData *imageData = nil;
    
    imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    return imageData;
}

- (UIImage*)imageFromData:(NSData*)data
{
    return [[UIImage alloc]initWithData:data];
}


#pragma mark Tesseract

-(void)recognizeImageWithTesseract:(UIImage *)image
{
    
    UIImage *bwImage = [image g8_blackAndWhite];
    
    //start animation
    [self animateProgress];
    
    self.imageToRecognize = bwImage;
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng+ukr+rus"];
    
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    operation.delegate = self;
    
    operation.tesseract.image = bwImage;
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        NSString *recognizedText = tesseract.recognizedText;
        
        NSLog(@"%@", recognizedText);
    
        //complete animation
        [self setOne];
        
        self.noteTextView.text = recognizedText;
    };
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract
{
    double proc = (double)tesseract.progress / 100;
    NSLog(@"%f", proc);
    
    [self.progresViewHUD setProgress:proc animated:YES];
   
    self.progresViewHUD.status = @"Processing";

}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to cancel recognition prematurely
}


#pragma mark - UITextViewDelegate
- (void)fixingTextViewDoneButton
{
    int padding = self.doneButton.frame.size.width + self.notePhotoButton.frame.size.width;
    self.noteTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, padding);
}

- (void)fixingZeroPaddingUITextView
{
    self.noteTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)address
{
    [self fixingTextViewDoneButton];
    self.notePhotoButton.hidden = NO;
    self.doneButton.hidden = NO;
    return  YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)address
{
    [self fixingZeroPaddingUITextView];
    self.notePhotoButton.hidden = YES;
    self.doneButton.hidden = YES;
    return YES;
}

#pragma mark - NoteWithPhoto
- (IBAction)noteWithPhotoButtonPressed:(id)sender
{
    [[self view] endEditing:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select action"
                                                               message:@"Select a photo?"
                                                        preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Camera"
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                          [self noteFromCamera];
                                                      }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Gallery"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           
                                                           [self noteFromGallary];
                                                           
                                                       }]; // 3
/*    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:@"Use already made photo."
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                          [self noteWithAlreadyMadePhoto];
                                                        }];*/

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                           
                                                       }]; // 3



    [alert addAction:firstAction]; // 4
    [alert addAction:secondAction]; // 5
    
  /*  if (self.imageToRecognize) {
        [alert addAction:thirdAction];
    }
    else {
        NSLog(@"Not found image.");
    }*/
    
    
    [alert addAction:cancelAction];


    [self presentViewController:alert animated:YES completion:nil]; // 6
    
}



- (void)noteFromCamera
{
    self.pickerForRecognizeImage = [[UIImagePickerController alloc] init];
    self.pickerForRecognizeImage.delegate = self;
    self.pickerForRecognizeImage.allowsEditing = YES;
    self.pickerForRecognizeImage.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.pickerForRecognizeImage animated:YES completion:NULL];
}

- (void)noteFromGallary
{
    self.pickerForRecognizeImage = [[UIImagePickerController alloc] init];
    self.pickerForRecognizeImage.delegate = self;
    self.pickerForRecognizeImage.allowsEditing = YES;
    self.pickerForRecognizeImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.pickerForRecognizeImage animated:YES completion:NULL];
}
/*
- (void)noteWithAlreadyMadePhoto
{
    if (self.imageToRecognize) {
        [self recognizeImageWithTesseract:self.imageToRecognize];
    }
    else {
        NSLog(@"Not found image.");
    }
}*/

#pragma mark - M13ProgressSuite

- (void)loadM13ProgressSuite
{
    self.progresViewHUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    self.progresViewHUD.progressViewSize = CGSizeMake(60.0, 60.0);
    self.progresViewHUD.animationPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:self.progresViewHUD];
}


- (void)animateProgress
{
    self.progresViewHUD.status = @"Proccesing";
    
    [self.progresViewHUD show:YES];
}

- (void)setOne
{
    [self.progresViewHUD setProgress:1.0 animated:YES];
    [self performSelector:@selector(setComplete) withObject:nil afterDelay:self.progresViewHUD.animationDuration + .1];
}

- (void)setComplete
{
    self.progresViewHUD.status = @"Complete";
    [self.progresViewHUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
}

- (void)reset
{
    [self.progresViewHUD setProgress:0.0 animated:NO];
    [self.progresViewHUD hide:YES];
    [self.progresViewHUD performAction:M13ProgressViewActionNone animated:NO];
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

//
//  CMXFeedbackViewController.m
//  CMX
//
//  Created by abhisbha on 3/31/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import "CMXFeedbackViewController.h"
#import "CMXClient.h"



@interface CMXFeedbackViewController() 

//the placeholder for the rating display
@property (strong, nonatomic) IBOutlet UIPickerView *rating;
//initialization for the rating display
@property (strong, nonatomic) NSArray *ratingArray;
//this is to recognize user taps somewhere on the screen outside the textfield. Based on its
//value we will hide the keypad
@property (strong, nonatomic) UITapGestureRecognizer *tap;
//placeholder for the user comment
@property (strong,nonatomic) UITextField *comment;
//final rating selected by the user
@property NSString *selectedRating;

@end


@implementation CMXFeedbackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize the array which will hold the options for the rating pickerview
    self.ratingArray  = [[NSArray alloc] initWithObjects:@"*",@"**",@"***",@"****",@"*****", nil];
    
    //this is the send button which will trigger the action to send to the cloud server
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Send" forState:UIControlStateNormal];
    button.frame = CGRectMake(254.0, 410.0, 36.0, 30.0);
    [self.view addSubview:button];
    
    //this is the textfield which will hold the user's comment
    _comment = [[UITextField alloc] initWithFrame:CGRectMake(20, 103, 285, 30)];
    _comment.textColor = [UIColor colorWithRed:0/256.0 green:84/256.0 blue:129/256.0 alpha:1.0];
    _comment.borderStyle = UITextBorderStyleRoundedRect;
    _comment.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:20];
    _comment.backgroundColor=[UIColor whiteColor];
    _comment.delegate = self;
    [self.view addSubview:self.comment];
    
    //the tap gesture recognizer.   
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = NO;
    [self.view addGestureRecognizer:_tap];
    
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return self.ratingArray.count;
    
}

-(NSString *)pickerView:(UIPickerView *)rating titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    
    return [self.ratingArray objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)rating didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    
    self.selectedRating = [NSString stringWithFormat:@"%ld",(long)(row+1)];
}

- (void)buttonPressed: (id)sender {
    
    [self sendFeedback];
    
}

-(void)sendFeedback {
    
    [[CMXClient instance]postFeedbackWithComment:self.comment.text
                                       andRating:self.selectedRating
                                       completion:^() {
                                           UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Success Alert Title", @"")
                                                                                               message: @"Feedback posted successfully !"
                                                                                              delegate: self
                                                                                     cancelButtonTitle: nil
                                                                                     otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                           [alertView show];
                                          
                                      }
                                         failure:^(NSError *error) {
                                             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CMX Error Alert Title", @"")
                                                                                                 message: error.localizedDescription
                                                                                                delegate: self
                                                                                       cancelButtonTitle: nil
                                                                                       otherButtonTitles: NSLocalizedString(@"CMX OK Button", @""), nil];
                                             [alertView show];
                                         }];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)comment
{
    _tap.enabled = YES;
    return YES;
}


-(void)hideKeyboard
{
    [self.comment resignFirstResponder];
    _tap.enabled = NO;
}




@end

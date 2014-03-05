/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Thursday, January 26, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <UIKit/UIKit.h>
#import "PickerViewController.h"

@interface CaptureProfileViewController : PickerViewController

@property(nonatomic) IBOutlet UILabel *myFormTitle;
@property(nonatomic) IBOutlet UITextField *myEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *myDisplayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *myFirstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *myLastNameTextField;
@property(nonatomic) IBOutlet UISegmentedControl *myGenderIdentitySegControl;
@property(nonatomic) IBOutlet UIButton *myBirthdayButton;
@property(nonatomic) IBOutlet UIDatePicker *myBirthdayPicker;
@property(nonatomic) IBOutlet UIToolbar *myPickerToolbar;
@property(nonatomic) IBOutlet UITextView *myAboutMeTextView;
@property(nonatomic) IBOutlet UIView *myPickerView;
@property(nonatomic) IBOutlet UIScrollView *myScrollView;
@property(nonatomic) IBOutlet UIToolbar *myKeyboardToolbar;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *myDoneButton;

- (IBAction)emailTextFieldClicked:(id)sender;

- (IBAction)displayNameFieldClicked:(id)sender;

- (IBAction)firstNameFieldClicked:(id)sender;

- (IBAction)lastNameFieldClicked:(id)sender;

- (IBAction)birthdayButtonClicked:(id)sender;

- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)doneEditingButtonPressed:(id)sender;
@end

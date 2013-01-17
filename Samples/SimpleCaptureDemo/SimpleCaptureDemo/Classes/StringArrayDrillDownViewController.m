/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "StringArrayDrillDownViewController.h"
#import "JSONKit.h"
#import "Utils.h"

@interface CellDatum : NSObject
@property (strong) NSString *stringValue;
@property (strong) UILabel  *titleLabel;
@property (strong) UILabel  *subtitleLabel;
@property (strong) UIView   *editingView;
@end

@implementation CellDatum
@synthesize stringValue;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize editingView;
@end

@interface StringArrayDrillDownViewController ()
{
    BOOL isEditing;
}
@property (nonatomic, retain) NSMutableArray *stringArray;
@property (nonatomic, retain) UIResponder *firstResponder;
@property (strong) JRCaptureObject *parentObject;
@property (strong) NSMutableArray  *cellData;
@property (strong) NSString        *tableHeader;
- (void)setCellTextForCellDatum:(CellDatum *)cellDatum atIndex:(NSUInteger)index;
- (void)createCellViewsForCellDatum:(CellDatum *)cellDatum atIndex:(NSUInteger)index;
@end

@implementation StringArrayDrillDownViewController
@synthesize parentObject;
@synthesize tableHeader;
@synthesize myTableView;
@synthesize myUpdateButton;
@synthesize myKeyboardToolbar;
@synthesize cellData;
@synthesize stringArray;
@synthesize firstResponder;

- (void)setTableDataWithArray:(NSArray *)array
{
    self.stringArray = [NSMutableArray arrayWithArray:array];
    self.cellData = [[NSMutableArray alloc] initWithCapacity:[stringArray count]];

    for (NSUInteger i = 0; i < [stringArray count]; i++)
    {
        CellDatum *cellDatum = [[CellDatum alloc] init];

        [self createCellViewsForCellDatum:cellDatum atIndex:i];
        [self setCellTextForCellDatum:cellDatum atIndex:i];

        [cellData addObject:cellDatum];
    }

    DLog(@"%@", [stringArray description]);
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil forArray:(NSArray*)array
  captureParentObject:(JRCaptureObject*)parentObject_ andKey:(NSString*)key
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.parentObject = parentObject_;
        self.tableHeader   = key;

        [self setTableDataWithArray:array];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                     target:self
                                                     action:@selector(editButtonPressed:)];

    self.navigationItem.rightBarButtonItem         = editButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    self.navigationItem.rightBarButtonItem.style   = UIBarButtonItemStyleBordered;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [myTableView reloadData];
}

- (IBAction)doneEditingTextButtonPressed:(id)sender
{
    [firstResponder resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstResponder = textField;
}

- (void)editButtonPressed:(id)sender
{
    DLog(@"");
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                     target:self
                                                     action:@selector(doneButtonPressed:)];

    self.navigationItem.rightBarButtonItem         = doneButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    self.navigationItem.rightBarButtonItem.style   = UIBarButtonItemStyleBordered;

    isEditing = YES;

    [myTableView reloadData];
}

- (void)doneButtonPressed:(id)sender
{
    DLog(@"");
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                     target:self
                                                     action:@selector(editButtonPressed:)];

    self.navigationItem.rightBarButtonItem         = editButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;

    self.navigationItem.rightBarButtonItem.style   = UIBarButtonItemStyleBordered;

    isEditing = NO;

    [firstResponder resignFirstResponder], firstResponder = nil;
    [myTableView reloadData];
}

- (void)saveLocalArrayToParentObject
{
    SEL setArraySelector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", upcaseFirst(tableHeader)]);

    [parentObject performSelector:setArraySelector withObject:[NSArray arrayWithArray:stringArray]];
}

- (IBAction)replaceButtonPressed:(id)sender
{
    DLog(@"");

    [self doneButtonPressed:nil];

    [self saveLocalArrayToParentObject];
    NSString *s = [NSString stringWithFormat:@"replace%@ArrayOnCaptureForDelegate:context:", upcaseFirst(tableHeader)];
    SEL replaceArraySelector = NSSelectorFromString(s);

    [parentObject performSelector:replaceArraySelector withObject:self withObject:nil];
}

- (void)addObjectButtonPressed:(UIButton *)sender
{
    DLog(@"");

    [stringArray addObject:[NSNull null]];

    CellDatum *objectData = [[CellDatum alloc] init];

    [self createCellViewsForCellDatum:objectData atIndex:[cellData count]];
    [self setCellTextForCellDatum:objectData atIndex:[cellData count]];

    [cellData addObject:objectData];

    [myTableView beginUpdates];
    [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[stringArray count] - 1
                                                                                    inSection:0]]
                       withRowAnimation:UITableViewRowAnimationLeft];
    [myTableView endUpdates];
}

#define EDITING_VIEW_OFFSET 100
#define LEFT_BUTTON_OFFSET  1000
#define RIGHT_BUTTON_OFFSET 2000
#define LEFT_LABEL_OFFSET   3000
#define DATE_PICKER_OFFSET  4000

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUInteger i = (NSUInteger) (textField.tag - EDITING_VIEW_OFFSET);
    CellDatum *cellDatum = [cellData objectAtIndex:i];

    cellDatum.stringValue = textField.text;
    [stringArray replaceObjectAtIndex:i withObject:textField.text];
    [self saveLocalArrayToParentObject];
    [self setCellTextForCellDatum:cellDatum atIndex:i];
    [myTableView reloadData];
}

- (void)deleteObjectButtonPressed:(UIButton *)sender
{
    DLog(@"");
    NSUInteger itemIndex = (NSUInteger) (sender.tag - LEFT_BUTTON_OFFSET);

    [stringArray removeObjectAtIndex:itemIndex];
    [cellData removeObjectAtIndex:itemIndex];

    [self saveLocalArrayToParentObject];

    [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:itemIndex inSection:0]]
                       withRowAnimation:UITableViewRowAnimationLeft];

    for (NSUInteger i = 0; i < [cellData count]; i++)
    {
        CellDatum *objectData = [cellData objectAtIndex:i];
        NSInteger oldIndex = objectData.editingView.tag - EDITING_VIEW_OFFSET;

        [objectData.editingView setTag:EDITING_VIEW_OFFSET + i];
        [[objectData.editingView viewWithTag:LEFT_BUTTON_OFFSET + oldIndex] setTag:LEFT_BUTTON_OFFSET + i];
        [[objectData.editingView viewWithTag:RIGHT_BUTTON_OFFSET + oldIndex] setTag:RIGHT_BUTTON_OFFSET + i];

        [self setCellTextForCellDatum:objectData atIndex:i];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return tableHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableHeader) return 30.0;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isEditing) return 260;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stringArray count] + 1;
}

- (void)setCellTextForCellDatum:(CellDatum *)cellDatum atIndex:(NSUInteger)index
{
    NSString *key = [NSString stringWithFormat:@"%@[%d]", tableHeader, index];
    id value = [stringArray objectAtIndex:index];

    if (value == [NSNull null]) value = @"null element";

    cellDatum.titleLabel.text    = key;
    cellDatum.subtitleLabel.text = value;
}

- (void)createCellViewsForCellDatum:(CellDatum *)cellDatum atIndex:(NSUInteger)index
{
    CGRect frame = CGRectMake(10, 5, (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 280 : 440, 18);
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:frame];
    keyLabel.backgroundColor  = [UIColor clearColor];
    keyLabel.font             = [UIFont systemFontOfSize:13.0];
    keyLabel.textColor        = [UIColor grayColor];
    keyLabel.textAlignment    = NSTextAlignmentLeft;
    keyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cellDatum.titleLabel = keyLabel;

    frame.origin.y     += 16;
    frame.size.height  += 8;
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:frame];
    valueLabel.backgroundColor  = [UIColor clearColor];
    valueLabel.font             = [UIFont boldSystemFontOfSize:16.0];
    valueLabel.textColor        = [UIColor grayColor];
    valueLabel.textAlignment    = NSTextAlignmentLeft;
    valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cellDatum.subtitleLabel = valueLabel;

    UITextField *editingView = [[UITextField alloc] initWithFrame:CGRectMake(20, 23,
            (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) ? 280 : 440, 22)];
    editingView.backgroundColor = [UIColor clearColor];
    editingView.font            = [UIFont systemFontOfSize:14.0];
    editingView.textColor       = [UIColor blackColor];
    editingView.textAlignment   = NSTextAlignmentLeft;
    editingView.hidden          = YES;
    editingView.borderStyle     = UITextBorderStyleLine;
    editingView.clearButtonMode = UITextFieldViewModeWhileEditing;
    editingView.delegate        = self;
    editingView.keyboardType    = UIKeyboardTypeDefault;
    editingView.inputAccessoryView = myKeyboardToolbar;
    editingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    editingView.tag = EDITING_VIEW_OFFSET + index;
    cellDatum.editingView = editingView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"");

    UITableViewCellStyle style = UITableViewCellStyleDefault;
    NSString *reuseIdentifier  = (indexPath.row == [stringArray count]) ? @"lastCell" : @"cachedCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (indexPath.row == [stringArray count])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = [NSString stringWithFormat:@"Add another %@ object", tableHeader];
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CellDatum *objectData = [cellData objectAtIndex:(NSUInteger) indexPath.row];

        for (UIView *view in [cell.contentView subviews]) [view removeFromSuperview];

        UILabel *titleLabel    = objectData.titleLabel;
        UILabel *subtitleLabel = objectData.subtitleLabel;
        UIView  *editingView   = objectData.editingView;

        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:subtitleLabel];
        [cell.contentView addSubview:editingView];

        editingView.hidden = !isEditing;
        subtitleLabel.hidden = isEditing;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"");
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.row == [stringArray count]) [self addObjectButtonPressed:nil];
}

- (void)replaceArrayDidFailForObject:(JRCaptureObject *)object arrayNamed:(NSString *)arrayName 
                           withError:(NSError *)error context:(NSObject *)context
{
    DLog(@"");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error.localizedFailureReason
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)replaceArrayDidSucceedForObject:(JRCaptureObject *)object newArray:(NSArray *)replacedArray 
                                  named:(NSString *)arrayName context:(NSObject *)context
{
    DLog(@"");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                        message:[replacedArray JSONString]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

    [self setTableDataWithArray:replacedArray];
    [myTableView reloadData];

    [SharedData saveCaptureUser];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end


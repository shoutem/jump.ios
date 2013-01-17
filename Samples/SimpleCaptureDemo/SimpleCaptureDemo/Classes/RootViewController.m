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

 Author: ${USER}
 Date:   ${DATE}
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "debug_log.h"
#import "RootViewController.h"
#import "JREngage+CustomInterface.h"
#import "CaptureProfileViewController.h"
#import "ObjectDrillDownViewController.h"

@interface RootViewController ()
- (void)configureButtons;
@end

@implementation RootViewController
@synthesize currentUserLabel;
@synthesize currentUserProviderIcon;
@synthesize browseButton;
@synthesize captureWidgetButton;
@synthesize updateButton;
@synthesize signInButton;
@synthesize signOutButton;
@synthesize shareWidgetButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureUserLabelAndIcon];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureButtons];
}

- (BOOL)isUserSignedIn
{
    return [SharedData sharedData].captureUser != nil;
}

- (void)configureButtons
{
    if ([self isUserSignedIn])
    {
        signInButton.hidden = YES;
        signOutButton.hidden = NO;
    }
    else
    {
        signInButton.hidden = NO;
        signOutButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self configureUserLabelAndIcon];
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    [browseButton setEnabled:enabled];
    [captureWidgetButton setEnabled:enabled];
    [updateButton setEnabled:enabled];
    [signInButton setEnabled:enabled];
    [signOutButton setEnabled:enabled];
}

- (IBAction)browseButtonPressed:(id)sender
{
    ObjectDrillDownViewController *drillDown =
        [[ObjectDrillDownViewController alloc] initWithNibName:@"ObjectDrillDownViewController"
                                                        bundle:[NSBundle mainBundle]
                                                     forObject:[SharedData sharedData].captureUser
                                           captureParentObject:nil
                                                        andKey:@"CaptureUser"];

    [[self navigationController] pushViewController:drillDown animated:YES];
}

- (IBAction)updateButtonPressed:(id)sender
{
    CaptureProfileViewController *viewController = [[CaptureProfileViewController alloc]
        initWithNibName:@"CaptureProfileViewController" bundle:[NSBundle mainBundle]];

    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)thirdButtonPressed:(id)sender
{
    [[SharedData sharedData] asyncFetchNewLiveFyreUserToken];
}

- (IBAction)signInButtonPressed:(id)sender
{
    [self setButtonsEnabled:NO];
    currentUserProviderIcon.image = nil;
    
    NSDictionary *customInterface = [NSDictionary dictionaryWithObject:self.navigationController
                                                                forKey:kJRApplicationNavigationController];
    
    [SharedData startAuthenticationWithCustomInterface:customInterface forDelegate:self];
}

- (IBAction)signOutButtonPressed:(id)sender
{
    currentUserLabel.text = @"No current user";
    currentUserProviderIcon.image = nil;
    [SharedData signOutCurrentUser];
    [self configureButtons];
}

- (void)configureUserLabelAndIcon
{
    if ([SharedData sharedData].captureUser)
        currentUserLabel.text = [NSString stringWithFormat:@"Email: %@", [SharedData sharedData].captureUser.email];
    else
        currentUserLabel.text = @"No current user";
    [self configureProviderIcon];
}

- (void)configureProviderIcon
{
    NSString *icon = [NSString stringWithFormat:@"icon_%@_30x30@2x.png", [SharedData sharedData].currentProvider];
    currentUserProviderIcon.image = [UIImage imageNamed:icon];
}

#pragma mark DemoSignInDelegate messages
- (void)engageSignInDidSucceed
{
    currentUserLabel.text = @"Signing in...";
    [self configureProviderIcon];
}

- (void)captureSignInDidSucceed
{
    [self setButtonsEnabled:YES];
    [self configureButtons];
    [self configureUserLabelAndIcon];

    if ([SharedData sharedData].isNotYetCreated || [SharedData sharedData].isNew)
    {
        CaptureProfileViewController *viewController = [[CaptureProfileViewController alloc]
            initWithNibName:@"CaptureProfileViewController" bundle:[NSBundle mainBundle]];

        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)engageSignInDidFailWithError:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)captureSignInDidFailWithError:(NSError *)error
{
    if ([error code] == JRCaptureErrorGenericBadPassword)
    {
        [[[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Invalid password for email@address.com"
                                  delegate:nil cancelButtonTitle:@"Dismiss"
                         otherButtonTitles:nil] show];
    }
    else
    {
        DLog(@"error: %@", [error description]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)viewDidUnload
{
    [self setShareWidgetButton:nil];
    [super viewDidUnload];
}

@end

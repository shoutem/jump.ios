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

 File:   QuickSignInAppDelegate.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import "QuickSignInAppDelegate.h"
#import "SplashViewController.h"
#import "RootViewController.h"

@implementation QuickSignInAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Override point for customization after app launch
    RootViewController *rvc = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    //[rvc autorelease]; // bad! see bullet near the bottom of:
                         // http://developer.apple.com/library/ios/#qa/qa1688/_index.html

    //requires iOS 5, breaking deployment down to 3, but that's fine until an app store update
    rvc.jrChildNavController = viewController;
    [rvc.view addSubview:viewController.view];

    [window addSubview:rvc.view];
    [window makeKeyAndVisible];
    //requires iOS 4, breaking deployment down to 3, but that's fine until an app store update
    if ([window respondsToSelector:@selector(setRootViewController:)])
        window.rootViewController = rvc;
}

// iOS 6
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window1
{
    //return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

@end

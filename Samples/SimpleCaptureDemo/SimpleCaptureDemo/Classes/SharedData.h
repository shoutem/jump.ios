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


#import <Foundation/Foundation.h>
#import "JRCaptureUser.h"
#import "JRCapture.h"

@protocol DemoSignInDelegate <NSObject>
@optional
- (void)engageSignInDidSucceed;

- (void)engageSignInDidFailWithError:(NSError *)error;

- (void)captureSignInDidSucceed;

- (void)captureSignInDidFailWithError:(NSError *)error;
@end

@interface SharedData : NSObject <JRCaptureSigninDelegate>
@property(readonly) BOOL engageSignInWasCanceled;
@property(readonly) JRCaptureUser *captureUser;
@property(readonly) BOOL isNew;
@property(readonly) BOOL isNotYetCreated;
@property(readonly) NSString *currentProvider;
@property(weak) id <DemoSignInDelegate> demoSignInDelegate;

+ (SharedData *)sharedData;

- (void)asyncFetchNewLiveFyreUserToken;

+ (void)startAuthenticationWithCustomInterface:(NSDictionary *)customInterface
                                   forDelegate:(id <DemoSignInDelegate>)delegate;

+ (void)saveCaptureUser;

+ (void)signOutCurrentUser;

@end


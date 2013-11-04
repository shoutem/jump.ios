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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import <GHUnitIOS/GHUnit.h>
#import "debug_log.h"
#import "SharedData.h"
#import "JRCaptureObject+Internal.h"
#import "ClassCategories.h"

@interface d1_CaptureUserTests : GHAsyncTestCase <JRCaptureObjectTesterDelegate, JRCaptureUserTesterDelegate>
{
    JRCaptureUser *captureUser;
}
@property(retain) JRCaptureUser *captureUser;
@end

@implementation d1_CaptureUserTests
@synthesize captureUser;

- (void)setUpClass
{
    DLog(@"");
    [SharedData initializeCapture];
}

- (void)tearDownClass
{
    DLog(@"");
    self.captureUser = nil;
}

- (void)setUp
{
    self.captureUser = [SharedData getBlankCaptureUser];
}

- (void)tearDown
{
    self.captureUser = nil;
}

- (void)test_d101_fetchLastUpdated
{
    GHAssertTrue(NO, @"Method fetchLastUpdatedFromServerForDelegate:context doesn't exist. Fix this test!");
//    [self prepare];
//    [captureUser fetchLastUpdatedFromServerForDelegate:self context:nil];
//    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)test_d111_codingEmptyUser
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:captureUser];
    JRCaptureUser *t = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    GHAssertTrue([captureUser isEqualToCaptureUser:t], nil);
    GHAssertTrue([captureUser isEqualByPrivateProperties:t], nil);
}

- (void)test_d112_codingFetchedUser
{
    // capture path dirty property set can be updated or replaced
    [self prepare];
    void (^t)(JRCaptureUser *, NSError *) = ^(JRCaptureUser *u, NSError *e) {
            if (u)
            {
                self.captureUser = u;
                NSMutableArray *a = [NSMutableArray arrayWithArray:self.captureUser.basicPlural];
                JRBasicPluralElement *const newElmt = [JRBasicPluralElement basicPluralElement];
                newElmt.string1 = @"sadf";
                [a addObject:newElmt];
                self.captureUser.basicPlural = a;
                [self test_d111_codingEmptyUser];
                DLog("success");
                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test_d112_codingFetchedUser)];
            }
            else GHFail(nil);
        };
    t = [t copy];
    [JRCaptureUser fetchCaptureUserFromServerForDelegate:self context:t];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    DLog("finished");
}

- (void)test_d120_readOnlyProps
{
    //captureUser.uuid = @"alskjf";
    //captureUser.lastUpdated = "sadf";
    //captureUser.created = "asdf";
}

JRCaptureUser *copyUserDirtyHack(JRCaptureUser *user)
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:user]];
}

JRCaptureUser *originalUser, *modifiedUser;
- (void)test_d130_dirtyFlagRestorationOnFailure
{
    [self prepare];

    UpdateCallback updateCallback = ^(JRCaptureObject *o, NSError *e_)
    {
        if (e_)
        {
            GHAssertFalse([originalUser isEqualByPrivateProperties:self.captureUser], nil);
            [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(test_d130_dirtyFlagRestorationOnFailure)];
        }
        else GHFail(nil);
    };
    updateCallback = [updateCallback copy];

    FetchCallback fetchCallback = ^(JRCaptureUser *u, NSError *e)
    {
        if (u)
        {
            self.captureUser = u;
            originalUser = copyUserDirtyHack(u);
            captureUser.basicDecimal = [NSNumber numberWithDouble:NAN];
            GHAssertFalse([originalUser isEqualByPrivateProperties:self.captureUser], nil);
            [captureUser updateOnCaptureForDelegate:self context:updateCallback];
        }
        else GHFail(nil);
    };
    fetchCallback = [fetchCallback copy];

    [JRCaptureUser fetchCaptureUserFromServerForDelegate:self context:fetchCallback];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    originalUser = nil;
}

- (void)test_d131_dirtyFlagsInPlurals
{
    [self prepare];

    UpdateCallback updateCallback = ^(JRCaptureObject *o, NSError *e_)
    {
        if (e_)
        {
            GHAssertFalse([originalUser isEqualByPrivateProperties:self.captureUser], nil);
            GHAssertTrue([modifiedUser isEqualByPrivateProperties:self.captureUser], nil);
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        }
        else GHFail(nil);
    };
    updateCallback = [updateCallback copy];

    FetchCallback fetchCallback = ^(JRCaptureUser *u, NSError *e)
    {
        if (u)
        {
            self.captureUser = u;
            originalUser = copyUserDirtyHack(u);
            captureUser.oinoinoL1Object.string1 = @"sadasdf99f";
            captureUser.oinoinoL1Object.oinoinoL2Object.string2 = @"asdlfkjaslfkdj";
            captureUser.oinoinoL1Object.oinoinoL2Object.oinoinoL3Object.string1 = @"asdlkfjaslkjf2";
            captureUser.basicDecimal = [NSNumber numberWithDouble:NAN];
            modifiedUser = copyUserDirtyHack(captureUser);

            GHAssertFalse([originalUser isEqualByPrivateProperties:self.captureUser], nil);
            [captureUser updateOnCaptureForDelegate:self context:updateCallback];
        }
        else GHFail(nil);
    };
    fetchCallback = [fetchCallback copy];

    [JRCaptureUser fetchCaptureUserFromServerForDelegate:self context:fetchCallback];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
    originalUser = nil;
    modifiedUser = nil;
}

- (void)test_d140_stringEquality
{
    JRCaptureUser *secondUserInstance = copyUserDirtyHack(self.captureUser);
    self.captureUser.basicString = @"asdf";
    secondUserInstance.basicString = [NSMutableString stringWithString:captureUser.basicString];
    GHAssertTrue(secondUserInstance.basicString != captureUser.basicString, nil);
    GHAssertTrue([captureUser isEqualToCaptureUser:secondUserInstance], nil);
}

- (void)fetchUserDidSucceed:(JRCaptureUser *)fetchedUser context:(NSObject *)context
{
    void (^block)(JRCaptureUser *, NSError *) = (void (^)(JRCaptureUser *, NSError *)) context;
    if ([context isKindOfClass:NSClassFromString(@"NSBlock")])
    {
        block(fetchedUser, nil);
        return;
    }

    GHFail(nil);
}

- (void)fetchUserDidFailWithError:(NSError *)error context:(NSObject *)context
{
    void (^block)(JRCaptureUser *, NSError *) = (void (^)(JRCaptureUser *, NSError *)) context;
    if ([context isKindOfClass:NSClassFromString(@"NSBlock")])
    {
        block(nil, error);
        return;
    }

    GHFail(nil);
}

- (void)updateDidSucceedForObject:(JRCaptureObject *)object context:(NSObject *)context
{
    void (^block)(JRCaptureObject *, NSError *) = (void (^)(JRCaptureObject *, NSError *)) context;
    if ([context isKindOfClass:NSClassFromString(@"NSBlock")])
    {
        block(object, nil);
        return;
    }

    GHFail(nil);
}

- (void)updateDidFailForObject:(JRCaptureObject *)object withError:(NSError *)error context:(NSObject *)context
{
    void (^block)(JRCaptureObject *, NSError *) = (void (^)(JRCaptureObject *, NSError *)) context;
    if ([context isKindOfClass:NSClassFromString(@"NSBlock")])
    {
        block(nil, error);
        return;
    }

    GHFail(nil);
}

- (void)fetchLastUpdatedDidFailWithError:(NSError *)error context:(NSObject *)context
{
    DLog("e: %@", [error description]);

    GHAssertFalse([captureUser respondsToSelector:NSSelectorFromString(@"lastUpdated")], nil);

    [self notify:kGHUnitWaitStatusSuccess];
}

- (void)fetchLastUpdatedDidSucceed:(JRDateTime *)serverLastUpdated
                        isOutdated:(BOOL)isOutdated
                           context:(NSObject *)context
{
    DLog("lu: %@ io: %d", [serverLastUpdated description], isOutdated);
    GHAssertTrue([captureUser respondsToSelector:NSSelectorFromString(@"lastUpdated")], nil);

    //GHAssertTrue(isOutdated != [serverLastUpdated isEqual:[captureUser lastUpdated]]);

    //[self notify:kGHUnitWaitStatusSuccess];
    [self notify:kGHUnitWaitStatusFailure];
}

@end

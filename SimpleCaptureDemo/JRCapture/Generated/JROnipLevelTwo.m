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

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


#import "JRCaptureObject+Internal.h"
#import "JROnipLevelTwo.h"

@interface JROnipLevelThree (OnipLevelThreeInternalMethods)
+ (id)onipLevelThreeObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath;
- (BOOL)isEqualToOnipLevelThree:(JROnipLevelThree *)otherOnipLevelThree;
@end

@interface JROnipLevelTwo ()
@property BOOL canBeUpdatedOrReplaced;
@end

@implementation JROnipLevelTwo
{
    NSString *_level;
    NSString *_name;
    JROnipLevelThree *_onipLevelThree;
}
@synthesize canBeUpdatedOrReplaced;

- (NSString *)level
{
    return _level;
}

- (void)setLevel:(NSString *)newLevel
{
    [self.dirtyPropertySet addObject:@"level"];

    [_level autorelease];
    _level = [newLevel copy];
}

- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)newName
{
    [self.dirtyPropertySet addObject:@"name"];

    [_name autorelease];
    _name = [newName copy];
}

- (JROnipLevelThree *)onipLevelThree
{
    return _onipLevelThree;
}

- (void)setOnipLevelThree:(JROnipLevelThree *)newOnipLevelThree
{
    [self.dirtyPropertySet addObject:@"onipLevelThree"];

    [_onipLevelThree autorelease];
    _onipLevelThree = [newOnipLevelThree retain];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.captureObjectPath      = @"";
        self.canBeUpdatedOrReplaced = NO;

        _onipLevelThree = [[JROnipLevelThree alloc] init];

        [self.dirtyPropertySet setSet:[NSMutableSet setWithObjects:@"level", @"name", @"onipLevelThree", nil]];
    }
    return self;
}

+ (id)onipLevelTwo
{
    return [[[JROnipLevelTwo alloc] init] autorelease];
}

- (id)copyWithZone:(NSZone*)zone
{
    JROnipLevelTwo *onipLevelTwoCopy = (JROnipLevelTwo *)[super copyWithZone:zone];

    onipLevelTwoCopy.level = self.level;
    onipLevelTwoCopy.name = self.name;
    onipLevelTwoCopy.onipLevelThree = self.onipLevelThree;

    return onipLevelTwoCopy;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:(self.level ? self.level : [NSNull null])
             forKey:@"level"];
    [dict setObject:(self.name ? self.name : [NSNull null])
             forKey:@"name"];
    [dict setObject:(self.onipLevelThree ? [self.onipLevelThree toDictionary] : [NSNull null])
             forKey:@"onipLevelThree"];

    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (id)onipLevelTwoObjectFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    if (!dictionary)
        return nil;

    JROnipLevelTwo *onipLevelTwo = [JROnipLevelTwo onipLevelTwo];

    onipLevelTwo.captureObjectPath = [NSString stringWithFormat:@"%@/%@", capturePath, @"onipLevelTwo"];
// TODO: Is this safe to assume?
    onipLevelTwo.canBeUpdatedOrReplaced = YES;

    onipLevelTwo.level =
        [dictionary objectForKey:@"level"] != [NSNull null] ?
        [dictionary objectForKey:@"level"] : nil;

    onipLevelTwo.name =
        [dictionary objectForKey:@"name"] != [NSNull null] ?
        [dictionary objectForKey:@"name"] : nil;

    onipLevelTwo.onipLevelThree =
        [dictionary objectForKey:@"onipLevelThree"] != [NSNull null] ?
        [JROnipLevelThree onipLevelThreeObjectFromDictionary:[dictionary objectForKey:@"onipLevelThree"] withPath:onipLevelTwo.captureObjectPath] : nil;

    [onipLevelTwo.dirtyPropertySet removeAllObjects];

    return onipLevelTwo;
}

- (void)updateFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    DLog(@"%@ %@", capturePath, [dictionary description]);

    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];

    self.canBeUpdatedOrReplaced = YES;
    self.captureObjectPath = [NSString stringWithFormat:@"%@/%@", capturePath, @"onipLevelTwo"];

    if ([dictionary objectForKey:@"level"])
        self.level = [dictionary objectForKey:@"level"] != [NSNull null] ?
            [dictionary objectForKey:@"level"] : nil;

    if ([dictionary objectForKey:@"name"])
        self.name = [dictionary objectForKey:@"name"] != [NSNull null] ?
            [dictionary objectForKey:@"name"] : nil;

    if ([dictionary objectForKey:@"onipLevelThree"] == [NSNull null])
        self.onipLevelThree = nil;
    else if ([dictionary objectForKey:@"onipLevelThree"] && !self.onipLevelThree)
        self.onipLevelThree = [JROnipLevelThree onipLevelThreeObjectFromDictionary:[dictionary objectForKey:@"onipLevelThree"] withPath:self.captureObjectPath];
    else if ([dictionary objectForKey:@"onipLevelThree"])
        [self.onipLevelThree updateFromDictionary:[dictionary objectForKey:@"onipLevelThree"] withPath:self.captureObjectPath];

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}

- (void)replaceFromDictionary:(NSDictionary*)dictionary withPath:(NSString *)capturePath
{
    DLog(@"%@ %@", capturePath, [dictionary description]);

    NSSet *dirtyPropertySetCopy = [[self.dirtyPropertySet copy] autorelease];

    self.canBeUpdatedOrReplaced = YES;
    self.captureObjectPath = [NSString stringWithFormat:@"%@/%@", capturePath, @"onipLevelTwo"];

    self.level =
        [dictionary objectForKey:@"level"] != [NSNull null] ?
        [dictionary objectForKey:@"level"] : nil;

    self.name =
        [dictionary objectForKey:@"name"] != [NSNull null] ?
        [dictionary objectForKey:@"name"] : nil;

    if (![dictionary objectForKey:@"onipLevelThree"] || [dictionary objectForKey:@"onipLevelThree"] == [NSNull null])
        self.onipLevelThree = nil;
    else if (!self.onipLevelThree)
        self.onipLevelThree = [JROnipLevelThree onipLevelThreeObjectFromDictionary:[dictionary objectForKey:@"onipLevelThree"] withPath:self.captureObjectPath];
    else
        [self.onipLevelThree replaceFromDictionary:[dictionary objectForKey:@"onipLevelThree"] withPath:self.captureObjectPath];

    [self.dirtyPropertySet setSet:dirtyPropertySetCopy];
}

- (NSDictionary *)toUpdateDictionary
{
    NSMutableDictionary *dict =
         [NSMutableDictionary dictionaryWithCapacity:10];

    if ([self.dirtyPropertySet containsObject:@"level"])
        [dict setObject:(self.level ? self.level : [NSNull null]) forKey:@"level"];

    if ([self.dirtyPropertySet containsObject:@"name"])
        [dict setObject:(self.name ? self.name : [NSNull null]) forKey:@"name"];

    if ([self.dirtyPropertySet containsObject:@"onipLevelThree"])
        [dict setObject:(self.onipLevelThree ?
                              [self.onipLevelThree toReplaceDictionaryIncludingArrays:NO] :
                              [[JROnipLevelThree onipLevelThree] toReplaceDictionaryIncludingArrays:NO]) /* Use the default constructor to create an empty object */
                 forKey:@"onipLevelThree"];
    else if ([self.onipLevelThree needsUpdate])
        [dict setObject:[self.onipLevelThree toUpdateDictionary]
                 forKey:@"onipLevelThree"];

    return dict;
}

- (NSDictionary *)toReplaceDictionaryIncludingArrays:(BOOL)includingArrays
{
    NSMutableDictionary *dict =
         [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:(self.level ? self.level : [NSNull null]) forKey:@"level"];
    [dict setObject:(self.name ? self.name : [NSNull null]) forKey:@"name"];

    [dict setObject:(self.onipLevelThree ?
                          [self.onipLevelThree toReplaceDictionaryIncludingArrays:YES] :
                          [[JROnipLevelThree onipLevelThree] toUpdateDictionary]) /* Use the default constructor to create an empty object */
             forKey:@"onipLevelThree"];

    return dict;
}

- (BOOL)needsUpdate
{
    if ([self.dirtyPropertySet count])
         return YES;

    if([self.onipLevelThree needsUpdate])
        return YES;

    return NO;
}

- (BOOL)isEqualToOnipLevelTwo:(JROnipLevelTwo *)otherOnipLevelTwo
{
    if (!self.level && !otherOnipLevelTwo.level) /* Keep going... */;
    else if ((self.level == nil) ^ (otherOnipLevelTwo.level == nil)) return NO; // xor
    else if (![self.level isEqualToString:otherOnipLevelTwo.level]) return NO;

    if (!self.name && !otherOnipLevelTwo.name) /* Keep going... */;
    else if ((self.name == nil) ^ (otherOnipLevelTwo.name == nil)) return NO; // xor
    else if (![self.name isEqualToString:otherOnipLevelTwo.name]) return NO;

    if (!self.onipLevelThree && !otherOnipLevelTwo.onipLevelThree) /* Keep going... */;
    else if (!self.onipLevelThree && [otherOnipLevelTwo.onipLevelThree isEqualToOnipLevelThree:[JROnipLevelThree onipLevelThree]]) /* Keep going... */;
    else if (!otherOnipLevelTwo.onipLevelThree && [self.onipLevelThree isEqualToOnipLevelThree:[JROnipLevelThree onipLevelThree]]) /* Keep going... */;
    else if (![self.onipLevelThree isEqualToOnipLevelThree:otherOnipLevelTwo.onipLevelThree]) return NO;

    return YES;
}

- (NSDictionary*)objectProperties
{
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithCapacity:10];

    [dict setObject:@"NSString" forKey:@"level"];
    [dict setObject:@"NSString" forKey:@"name"];
    [dict setObject:@"JROnipLevelThree" forKey:@"onipLevelThree"];

    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)dealloc
{
    [_level release];
    [_name release];
    [_onipLevelThree release];

    [super dealloc];
}
@end

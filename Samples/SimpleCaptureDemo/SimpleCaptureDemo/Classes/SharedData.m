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

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#import "SharedData.h"
#import "JSONKit.h"
#import "JRConnectionManager.h"

#define cJRCurrentProvider  @"simpleCaptureDemo.currentProvider"
#define cJRCaptureUser      @"simpleCaptureDemo.captureUser"

@interface JRCapture (private_methods)
+(void)clearSignInState;
@end

@interface SharedData ()
@property(strong) NSUserDefaults *prefs;
@property(strong) JRCaptureUser *captureUser;
@property BOOL isNew;
@property BOOL isNotYetCreated;
@property(strong) NSString *currentProvider;
@property BOOL engageSignInWasCanceled;
@property(nonatomic) NSString *lfToken;
@property(nonatomic, strong) NSString *captureClientId;
@property(nonatomic, strong) NSString *captureUIDomain;
@property(nonatomic, strong) NSString *captureApidDomain;
@property(nonatomic, strong) NSString *engageAppId;
@property(nonatomic, strong) NSString *bpBusUrlString;
@property(nonatomic, strong) NSString *bpChannelUrl;
@property(nonatomic, strong) NSString *liveFyreNetwork;
@property(nonatomic, strong) NSString *liveFyreSiteId;
@property(nonatomic, strong) NSString *liveFyreArticleId;
@end

@implementation SharedData
static SharedData *singleton = nil;

@synthesize captureUser;
@synthesize currentProvider;
@synthesize demoSignInDelegate;
@synthesize isNew;
@synthesize isNotYetCreated;
@synthesize engageSignInWasCanceled;
@synthesize bpChannelUrl;
@synthesize lfToken;
@synthesize captureClientId;
@synthesize captureUIDomain;
@synthesize captureApidDomain;
@synthesize engageAppId;
@synthesize bpBusUrlString;
@synthesize liveFyreNetwork;
@synthesize liveFyreSiteId;
@synthesize liveFyreArticleId;
@synthesize prefs;

- (id)init
{
    if ((self = [super init]))
    {
        [self loadConfigFromPlist];
        [JRCapture setEngageAppId:engageAppId captureApidDomain:captureApidDomain
                  captureUIDomain:captureUIDomain clientId:captureClientId andEntityTypeName:nil];
        [self asyncFetchNewBackplaneChannel];

        self.prefs = [NSUserDefaults standardUserDefaults];

        self.currentProvider  = [prefs objectForKey:cJRCurrentProvider];

        NSData *archivedCaptureUser = [prefs objectForKey:cJRCaptureUser];
        if (archivedCaptureUser)
        {
            self.captureUser = [NSKeyedUnarchiver unarchiveObjectWithData:archivedCaptureUser];
        }
    }

    return self;
}

- (void)loadConfigFromPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"assets/janrain-config" ofType:@"plist"];
    NSDictionary *cfgPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *configKeyName = [cfgPlist objectForKey:@"default-config"];
    NSDictionary *cfg = [cfgPlist objectForKey:configKeyName];

    self.captureClientId = [cfg objectForKey:@"captureClientId"];
    self.captureUIDomain = [cfg objectForKey:@"captureUIDomain"];
    self.captureApidDomain = [cfg objectForKey:@"captureApidDomain"];
    self.engageAppId = [cfg objectForKey:@"engageAppId"];
    self.bpBusUrlString = [cfg objectForKey:@"bpBusUrlString"];
    self.bpChannelUrl = [cfg objectForKey:@"bpChannelUrl"];
    self.liveFyreNetwork = [cfg objectForKey:@"liveFyreNetwork"];
    self.liveFyreSiteId = [cfg objectForKey:@"liveFyreSiteId"];
    self.liveFyreArticleId = [cfg objectForKey:@"liveFyreArticleId"];
}

- (void)asyncFetchNewBackplaneChannel
{
    if (!bpBusUrlString) return;
    NSURL *bpNewChanUrl = [NSURL URLWithString:[bpBusUrlString stringByAppendingString:@"/channel/new"]];
    NSURLRequest *req = [NSURLRequest requestWithURL:bpNewChanUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                     timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
                           {
                               NSInteger code = [((NSHTTPURLResponse *) r) statusCode];
                               if (e || code != 200)
                               {
                                   ALog(@"Err fetching new BP channel: %@, code: %i", e, code);
                               }
                               else
                               {
                                   NSString *body = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
                                   NSCharacterSet *quoteSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
                                   NSString *bpChannel = [body stringByTrimmingCharactersInSet:quoteSet];
                                   NSString *bpChannelUrl_ = [bpBusUrlString stringByAppendingFormat:@"/channel/%@",
                                                                            bpChannel];
                                   DLog(@"New BP channel: %@", bpChannelUrl_);
                                   self.bpChannelUrl = bpChannelUrl_;
                                   [JRCapture setBackplaneChannelUrl:bpChannelUrl_];
                               }
                           }];
}

- (void)asyncFetchNewLiveFyreUserToken
{
    if (!liveFyreArticleId || !liveFyreNetwork || !liveFyreSiteId) return;
    NSString *lfAuthUrl = [NSString stringWithFormat:@"http://admin.%@/api/v3.0/auth?bp_channel=%@&siteId=%@"
                                                             "&articleId=%@",
                                                     liveFyreNetwork,
                                                     [self.bpChannelUrl stringByAddingUrlPercentEscapes],
                                                     liveFyreSiteId,
                                                     [liveFyreArticleId stringByAddingUrlPercentEscapes]];
    DLog(@"Fetching LF token from %@", lfAuthUrl);
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:lfAuthUrl]
                                         cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                     timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e)
                           {
                               NSString *body = d ? [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]
                                       : nil;
                               NSInteger code = [((NSHTTPURLResponse *) r) statusCode];
                               if (e || code != 200)
                               {
                                   ALog(@"Err fetching LF token: %@, code: %i, body: %@", e, code, body);
                               }
                               else
                               {
                                   NSDictionary *lfResponse = [body objectFromJSONString];
                                   if (!lfResponse)
                                   {
                                       ALog(@"Error parsing LF response: %@", body);
                                       return;
                                   }
                                   NSString *lfToken_ = [[lfResponse objectForKey:@"data"] objectForKey:@"token"];
                                   if (!lfToken_) {
                                       ALog(@"Error retrieving token from LF response: %@", body);
                                       return;
                                   }
                                   DLog(@"New LF token: %@", lfToken_);
                                   self.lfToken = lfToken_;
                               }
                           }];

}

+ (SharedData *)sharedData
{
    if (singleton == nil) {
        singleton = (SharedData *) [[super allocWithZone:NULL] init];
    }

    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedData];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)signOutCurrentUser
{
    self.currentProvider  = nil;
    self.captureUser      = nil;

    self.isNew         = NO;
    self.isNotYetCreated = NO;

    [prefs setObject:nil forKey:cJRCurrentProvider];
    [prefs setObject:nil forKey:cJRCaptureUser];

    self.engageSignInWasCanceled = NO;

    [JRCapture clearSignInState];
}

+ (void)signOutCurrentUser
{
    [[SharedData sharedData] signOutCurrentUser];
}

+ (void)startAuthenticationWithCustomInterface:(NSDictionary *)customInterface
                                   forDelegate:(id<DemoSignInDelegate>)delegate
{
    [SharedData signOutCurrentUser];
    [[SharedData sharedData] setDemoSignInDelegate:delegate];

    [JRCapture startEngageSigninDialogWithConventionalSignin:JRConventionalSigninEmailPassword
                                 andCustomInterfaceOverrides:customInterface
                                                 forDelegate:[SharedData sharedData]];
}

- (void)saveCaptureUser
{
    [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:captureUser] forKey:cJRCaptureUser];
}

+ (void)saveCaptureUser
{
    [[SharedData sharedData] saveCaptureUser];
}

- (void)postEngageErrorToDelegate:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    if ([demoSignInDelegate respondsToSelector:@selector(engageSignInDidFailWithError:)])
        [demoSignInDelegate engageSignInDidFailWithError:error];
}

- (void)postCaptureErrorToDelegate:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    if ([demoSignInDelegate respondsToSelector:@selector(captureSignInDidFailWithError:)])
        [demoSignInDelegate captureSignInDidFailWithError:error];
}

- (void)engageSigninDidNotComplete
{
    DLog(@"");
    self.engageSignInWasCanceled = YES;

    [self postEngageErrorToDelegate:nil];
}

- (void)engageSigninDialogDidFailToShowWithError:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    [self postEngageErrorToDelegate:error];
}

- (void)engageAuthenticationDidFailWithError:(NSError *)error
                                 forProvider:(NSString *)provider
{
    DLog(@"error: %@", [error description]);
    [self postEngageErrorToDelegate:error];
}

- (void)captureAuthenticationDidFailWithError:(NSError *)error
{
    DLog(@"error: %@", [error description]);
    [self postCaptureErrorToDelegate:error];
}

- (void)engageSigninDidSucceedForUser:(NSDictionary *)engageAuthInfo
                          forProvider:(NSString *)provider
{
    self.currentProvider = provider;
    [prefs setObject:currentProvider forKey:cJRCurrentProvider];

    if ([demoSignInDelegate respondsToSelector:@selector(engageSignInDidSucceed)])
        [demoSignInDelegate engageSignInDidSucceed];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)captureAuthenticationDidSucceedForUser:(JRCaptureUser *)newCaptureUser
                                        status:(JRCaptureRecordStatus)captureRecordStatus
{
    DLog(@"");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (captureRecordStatus == JRCaptureRecordNewlyCreated)
        self.isNew = YES;
    else
        self.isNew = NO;

    if (captureRecordStatus == JRCaptureRecordMissingRequiredFields)
        self.isNotYetCreated = YES;
    else
        self.isNotYetCreated = NO;

    self.captureUser = newCaptureUser;

    [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:captureUser]
                     forKey:cJRCaptureUser];

    if ([demoSignInDelegate respondsToSelector:@selector(captureSignInDidSucceed)])
        [demoSignInDelegate captureSignInDidSucceed];

    engageSignInWasCanceled = NO;
}
@end

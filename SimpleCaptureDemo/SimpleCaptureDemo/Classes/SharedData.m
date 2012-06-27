//
//  Created by lillialexis on 2/25/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#import "SharedData.h"
#import "JRCaptureUser+Extras.h"
#import "JRCaptureObject+Internal.h"

@interface SharedData ()
@property (nonatomic, retain) JREngage *jrEngage;
@property (strong) NSUserDefaults      *prefs;
@end

@implementation SharedData
static SharedData *singleton = nil;

static NSString *appId              = @"appcfamhnpkagijaeinl";
static NSString *captureApidDomain  = @"https://mobile.dev.janraincapture.com";
static NSString *captureUIDomain    = @"https://mobile.dev.janraincapture.com";
static NSString *clientId           = @"zc7tx83fqy68mper69mxbt5dfvd7c2jh";
static NSString *entityTypeName     = @"user_dev";

///* Carl's local instance */
//static NSString *appId             = @"pgfjodcppiaifejikhmh";
//static NSString *captureApidDomain = @"http://10.0.10.47:8000";
//static NSString *captureUIDomain   = @"http://10.0.10.47:5000";
//static NSString *clientId          = @"puh6d29gb94mn9ek4v3w8f7w9hp58g2z";
//static NSString *entityTypeName    = @"user2";

//static NSString *appId          = @"mlfeingbenjalleljkpo";
//static NSString *captureDomain  = @"https://demo.staging.janraincapture.com/";
//static NSString *clientId       = @"svaf3gxsmcvyfpx5vcrdwyv2axvy9zqg";
//static NSString *entityTypeName = @"demo_user";

@synthesize engageUser;
@synthesize captureUser;
@synthesize accessToken;
@synthesize creationToken;
@synthesize prefs;
@synthesize jrEngage;
@synthesize currentDisplayName;
@synthesize currentProvider;
@synthesize signInDelegate;
@synthesize isNew;
@synthesize notYetCreated;


- (id)init
{
    if ((self = [super init]))
    {
        [JRCapture setCaptureApiDomain:captureApidDomain captureUIDomain:captureUIDomain
                              clientId:clientId andEntityTypeName:entityTypeName];

        [JRCapture setEngageAppId:appId];
//        self.jrEngage = [JREngage jrEngageWithAppId:appId
//                                        andTokenUrl:[JRCapture captureMobileEndpointUrl]
//                                           delegate:self];

        self.prefs = [NSUserDefaults standardUserDefaults];
        self.engageUser = [NSMutableDictionary dictionaryWithDictionary:[prefs objectForKey:@"engageUser"]];
        self.captureUser = [JRCaptureUser captureUserObjectFromDictionary:[prefs objectForKey:@"captureUser"]];
        self.accessToken = [prefs objectForKey:@"accessToken"];
        self.creationToken = [prefs objectForKey:@"creationToken"];
        self.currentDisplayName = [prefs objectForKey:@"currentDisplayName"];
        self.currentProvider = [prefs objectForKey:@"currentProvider"];

        DLog(@"%@", [prefs objectForKey:@"captureUser"]);

        [JRCapture setAccessToken:accessToken];
        [JRCapture setCreationToken:creationToken];
//        captureUser.accessToken = accessToken;
//        captureUser.creationToken = creationToken;
    }

    return self;
}

/* Return the singleton instance of this class. */
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

//- (id)retain
//{
//    return self;
//}

//- (NSUInteger)retainCount
//{
//    return NSUIntegerMax; /* Denotes an object that cannot be released */
//}

//- (oneway void)release { /* Do nothing */ }

//- (id)autorelease
//{
//    return self;
//}

- (void)startAuthenticationWithCustomInterface:(NSDictionary *)customInterface forDelegate:(id<SignInDelegate>)delegate
{
    [self setSignInDelegate:delegate];
    [JRCapture startAuthenticationDialogWithNativeSignin:JRNativeSigninNone
                             andCustomInterfaceOverrides:customInterface forDelegate:self];
    //[jrEngage showAuthenticationDialogWithCustomInterfaceOverrides:customInterface];
}

+ (NSString*)getDisplayNameFromProfile:(NSDictionary*)profile
{
    NSString *name = nil;

    if ([profile objectForKey:@"preferredUsername"])
        name = [NSString stringWithFormat:@"%@", [profile objectForKey:@"preferredUsername"]];
    else if ([[profile objectForKey:@"name"] objectForKey:@"formatted"])
        name = [NSString stringWithFormat:@"%@",
                [[profile objectForKey:@"name"] objectForKey:@"formatted"]];
    else
        name = [NSString stringWithFormat:@"%@%@%@%@%@",
                ([[profile objectForKey:@"name"] objectForKey:@"honorificPrefix"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"honorificPrefix"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"givenName"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"givenName"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"middleName"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"middleName"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"familyName"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"familyName"]] : @"",
                ([[profile objectForKey:@"name"] objectForKey:@"honorificSuffix"]) ?
                [NSString stringWithFormat:@"%@ ",
                 [[profile objectForKey:@"name"] objectForKey:@"honorificSuffix"]] : @""];

    return name;
}

/**
 * Horrible hack to remove NSNulls from profile data to allow it to be stored in an NSUserDefaults
 * (Capture profiles can have null values and JSONKit parses them to NSNulls, but Engage profiles don't and so
 * didn't trigger this incompatibility.)
 */
// TODO: Can't do this; need nulls... instead, turn dictionary into string and save that, then back again
- (id)nullWalker:(id)structure
{
    if ([structure isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *) structure;
        NSMutableDictionary *retval = [NSMutableDictionary dictionary];
        NSArray *keys = [dict allKeys];
        for (NSString *key in keys)
        {
            NSObject *val = [dict objectForKey:key];
            if ([val isKindOfClass:[NSNull class]])
                /* don't add */;
            else if ([val isKindOfClass:[NSDictionary class]])
                [retval setObject:[self nullWalker:val] forKey:key];
            else if ([val isKindOfClass:[NSArray class]])
                [retval setObject:[self nullWalker:val] forKey:key];
            else
                [retval setObject:val forKey:key];
        }
        return retval;
    }
    else if ([structure isKindOfClass:[NSArray class]])
    {
        NSArray *array = (NSArray *) structure;
        NSMutableArray *retval = [NSMutableArray array];
        for (NSObject *val in array)
            if ([val isKindOfClass:[NSNull class]])
                /* don't add */;
            else if ([val isKindOfClass:[NSDictionary class]])
                [retval addObject:[self nullWalker:val]];
            else if ([val isKindOfClass:[NSArray class]])
                [retval addObject:[self nullWalker:val]];
            else
                [retval addObject:val];
        return retval;
    }
    else
    {
        ALog(@"Unrecognized stucture: %@", [structure description]);
        return nil;
        // TODO: Better error handling
    }
}

- (void)resaveCaptureUser
{
    [prefs setObject:[self nullWalker:[captureUser toDictionary]] forKey:@"captureUser"];
}

- (void)jrAuthenticationCallToTokenUrl:(NSString *)tokenUrl didFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    if ([signInDelegate respondsToSelector:@selector(engageSignInDidFailWithError:)])
        [signInDelegate engageSignInDidFailWithError:error];
}

- (void)jrAuthenticationDidFailWithError:(NSError *)error forProvider:(NSString *)provider
{
    if ([signInDelegate respondsToSelector:@selector(engageSignInDidFailWithError:)])
        [signInDelegate engageSignInDidFailWithError:error];
}

- (void)jrAuthenticationDidNotComplete
{
    if ([signInDelegate respondsToSelector:@selector(engageSignInDidFailWithError:)])
        [signInDelegate engageSignInDidFailWithError:nil];
}

- (void)jrAuthenticationDidSucceedForUser:(NSDictionary *)auth_info forProvider:(NSString *)provider
{
    self.engageUser    = [NSMutableDictionary dictionaryWithDictionary:auth_info];

    currentDisplayName = [SharedData getDisplayNameFromProfile:[engageUser objectForKey:@"profile"]];
    currentProvider    = [provider copy];

    [prefs setObject:engageUser forKey:@"engageUser"];
    [prefs setObject:currentDisplayName forKey:@"currentDisplayName"];
    [prefs setObject:currentProvider forKey:@"currentProvider"];

    if ([signInDelegate respondsToSelector:@selector(engageSignInDidSucceed)])
        [signInDelegate engageSignInDidSucceed];
}

- (void)jrAuthenticationDidReachTokenUrl:(NSString *)tokenUrl withResponse:(NSURLResponse *)response
                              andPayload:(NSData *)tokenUrlPayload forProvider:(NSString *)provider
{
    DLog(@"");

    NSString     *payload     = [[NSString alloc] initWithData:tokenUrlPayload encoding:NSUTF8StringEncoding];
    NSDictionary *payloadDict = [payload objectFromJSONString];

    DLog(@"token url payload: %@", [payload description]);

    if (!payloadDict)
    {
        ALog(@"Unable to parse token URL response: %@", payload);
        if ([signInDelegate respondsToSelector:@selector(captureSignInDidFailWithError:)])
            [signInDelegate engageSignInDidFailWithError:nil];

        return;
    }

    self.accessToken   = [payloadDict objectForKey:@"access_token"];
    self.creationToken = [payloadDict objectForKey:@"creation_token"];
    self.isNew         = [(NSNumber*)[payloadDict objectForKey:@"is_new"] boolValue];
    self.notYetCreated = creationToken ? YES: NO;

//<<<<<<< HEAD
//    if (accessToken)
//    {
//        NSDictionary *captureProfile = [payloadDict objectForKey:@"profile"];//[self nullWalker:[payloadDict objectForKey:@"profile"]];
//
//        DLog(@"user dictionary: %@", [captureProfile description]);
//        self.captureUser = [JRCaptureUser captureUserObjectFromDictionary:captureProfile];
//
//        captureUser.statuses = nil;
//        captureUser.aboutMe = nil;
//
//        NSDictionary *backAgain = [captureUser dictionaryFromObject];
//
//        DLog(@"user dictionary back again: %@", [backAgain description]);
//        DLog(@"json string: %@", [backAgain JSONString]);
//
//    }
//    else if (creationToken)
//    {
//        self.captureUser = [JRCaptureUser captureUser];
//
//        captureUser.email = [[engageUser objectForKey:@"profile"] objectForKey:@"email"];
//
//        JRProfiles *profilesObject = (JRProfiles *) [JRCapture captureProfilesObjectFromEngageAuthInfo:engageUser];
//
//        if (profilesObject)
//            captureUser.profiles = [NSArray arrayWithObject:profilesObject];
//    }
//=======

    NSDictionary *captureProfile = [payloadDict objectForKey:@"capture_user"];
    self.captureUser = [JRCaptureUser captureUserObjectFromDictionary:captureProfile];

//    [captureUser setAccessToken:accessToken];
//    [captureUser setCreationToken:creationToken];

    [JRCapture setAccessToken:accessToken];
    [JRCapture setCreationToken:creationToken];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [prefs setObject:engageUser forKey:@"engageUser"];
    [prefs setObject:[self nullWalker:[captureUser toDictionary]] forKey:@"captureUser"];
    [prefs setObject:accessToken forKey:@"accessToken"];
    [prefs setObject:creationToken forKey:@"creationToken"];

    if ([signInDelegate respondsToSelector:@selector(captureSignInDidSucceed)])
        [signInDelegate captureSignInDidSucceed];
}

- (void)jrEngageDialogDidFailToShowWithError:(NSError *)error
{
    if ([signInDelegate respondsToSelector:@selector(engageSignInDidFailWithError:)])
        [signInDelegate engageSignInDidFailWithError:error];
}

- (void)jrAuthenticationDidSucceedForUser:(JRCaptureUser *)newCaptureUser withToken:(NSString *)captureToken andStatus:(JRCaptureRecordStatus)status
{

}


@end

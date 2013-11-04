# Native Authentication Guide

This guide describes the process of integrating with native iOS authentication systems. The Engage library has
historically supported authentication by means of a UIWebView running a traditional web OAuth flow. Support is now
introduced for authentication by means of native identity-provider libraries.

## Supported Providers

- Facebook

Google+ support is coming soon, Twitter support is being investigated.

Native Authentication is supported by the Engage library, and is compatible with both Engage-only and Engage-and-
Capture deployments.

At this time native-authentication is available for authentication only, and not for social-identity-resource
authorization (e.g. sharing.)

## 10,000' View

1. Configure the native authentication framework
2. Start JUMP sign-in or Engage authentication
3. The Janrain library will delegate the authentication to the native authentication framework
4. The Janrain library delegate message will fire when native authentication completes

## Configure the Native Authentication Framework

Follow the Facebook iOS SDK integration instructions. For native Facebook authentication to work via Engage both Engage
and the Facebook iOS SDK must be configured to use the same "Facebook application".

Make sure that you use the same Facebook app ID as is configured in your Engage application's dashboard.

### Ensure the Linker Does Not Discard The Symbols

If the symbols used in the Facebook SDK are not directly referenced by the host application they will be disacarded
by the linker. (The JUMP SDK does not reference them directly.)

To ensure that the symbols won't be discarded add a reference to them in your AppDelegate:

    #import "FacebookSDK/FacebookSDK.h"

    // ...

        FBSession *linkerGuard = FBSession.activeSession;

## Begin Sign-In or Authentication

Start authentication or sign-in as normal (described in `JUMP Integration Guide.md` and
`Engage-Only Integration Guide.md`.) If the Facebook iOS SDK is compiled into your app, it will be used to perform
all Facebook authentication.

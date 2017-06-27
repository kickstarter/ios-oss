// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

/**

  The FBSDKApplicationDelegate is designed to post process the results from Facebook Login
 or Facebook Dialogs (or any action that requires switching over to the native Facebook
 app or Safari).



 The methods in this class are designed to mirror those in UIApplicationDelegate, and you
 should call them in the respective methods in your AppDelegate implementation.
 */
@interface FBSDKApplicationDelegate : NSObject

/**
  Gets the singleton instance.
 */
+ (instancetype)sharedInstance;

/**
  Call this method from the [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method
 of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
 with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs.

 - Parameter application: The application as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].

 - Parameter url: The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].

 - Parameter sourceApplication: The sourceApplication as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].

 - Parameter annotation: The annotation as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].

 - Returns: YES if the url was intended for the Facebook SDK, NO if not.
  */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_0
/**
  Call this method from the [UIApplicationDelegate application:openURL:options:] method
 of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
 with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs.

 - Parameter application: The application as passed to [UIApplicationDelegate application:openURL:options:].

 - Parameter url: The URL as passed to [UIApplicationDelegate application:openURL:options:].

 - Parameter options: The options dictionary as passed to [UIApplicationDelegate application:openURL:options:].

 - Returns: YES if the url was intended for the Facebook SDK, NO if not.
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
#endif

/**
  Call this method from the [UIApplicationDelegate application:didFinishLaunchingWithOptions:] method
 of the AppDelegate for your app. It should be invoked for the proper use of the Facebook SDK.
 As part of SDK initialization basic auto logging of app events will occur, this can be
controlled via 'FacebookAutoLogAppEventsEnabled' key in the project info plist file.

 - Parameter application: The application as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].

 - Parameter launchOptions: The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].

 - Returns: YES if the url was intended for the Facebook SDK, NO if not.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end

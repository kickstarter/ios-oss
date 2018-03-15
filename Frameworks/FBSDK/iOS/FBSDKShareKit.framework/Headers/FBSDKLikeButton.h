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

#import <FBSDKCoreKit/FBSDKButton.h>

#import <FBSDKShareKit/FBSDKLikeObjectType.h>
#import <FBSDKShareKit/FBSDKLiking.h>

/**
  Warning: This class is deprecated.
  A button to like an object.

 Tapping the receiver will invoke an API call to the Facebook app through a fast-app-switch that allows
 the object to be liked.  Upon return to the calling app, the view will update with the new state.  If the
 currentAccessToken has "publish_actions" permission and the object is an Open Graph object, then the like can happen
 seamlessly without the fast-app-switch.
 */
__attribute__ ((deprecated))
@interface FBSDKLikeButton : FBSDKButton <FBSDKLiking>

/**
  If YES, a sound is played when the receiver is toggled.

 @default YES
 */
@property (nonatomic, assign, getter = isSoundEnabled) BOOL soundEnabled;

@end

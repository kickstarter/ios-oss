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

#import <FBSDKCoreKit/FBSDKCopying.h>

/**
 * A container of textures for a camera effect.
 * A texture for a camera effect is an UIImages identified by a NSString key.
 */
@interface FBSDKCameraEffectTextures : NSObject <FBSDKCopying, NSSecureCoding>

/**
 Sets the image for a texture key.
 - Parameter image: The UIImage for the texture
 - Parameter name: The key for the texture
 */
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

/**
 Gets the image for a texture key.
 - Parameter name: The key for the texture
 - Returns: The texture UIImage or nil
 */
- (UIImage *)imageForKey:(NSString *)key;

@end

/** @file FirebaseAuth.h
    @brief Firebase Auth SDK
    @copyright Copyright 2015 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
        https://developers.google.com/terms/
 */

#import <FirebaseAuth/FIREmailPasswordAuthProvider.h>
#import <FirebaseAuth/FIRFacebookAuthProvider.h>
#import <FirebaseAuth/FIRGitHubAuthProvider.h>
#import <FirebaseAuth/FIRGoogleAuthProvider.h>
#import <FirebaseAuth/FIRTwitterAuthProvider.h>
#import <FirebaseAuth/FIRAuth.h>
#import <FirebaseAuth/FIRAuthCredential.h>
#import <FirebaseAuth/FIRAuthErrors.h>
#import <FirebaseAuth/FIRUser.h>
#import <FirebaseAuth/FIRUserInfo.h>

/** @var FirebaseAuthVersionNumber
    @brief Version number for FirebaseAuth.
 */
extern const double FirebaseAuthVersionNumber;

/** @var FirebaseAuthVersionString
    @brief Version string for FirebaseAuth.
 */
extern const unsigned char *const FirebaseAuthVersionString;

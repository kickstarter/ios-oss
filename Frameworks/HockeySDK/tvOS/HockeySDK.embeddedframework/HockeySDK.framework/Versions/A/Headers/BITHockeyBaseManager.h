#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 The internal superclass for all component managers
 
 */

@interface BITHockeyBaseManager : NSObject

///-----------------------------------------------------------------------------
/// @name Modules
///-----------------------------------------------------------------------------


/**
 Defines the server URL to send data to or request data from
 
 By default this is set to the HockeyApp servers and there rarely should be a
 need to modify that.
 */
@property (nonatomic, copy) NSString *serverURL;


///-----------------------------------------------------------------------------
/// @name User Interface
///-----------------------------------------------------------------------------

/**
 The navigationbar tint color of the update user interface navigation bar.
 
 The navigationBarTintColor is used by default, you can either overwrite it `navigationBarTintColor`
 or define another `barStyle` instead.
 
 Default is RGB(25, 25, 25)
 @see barStyle
 */
@property (nonatomic, strong) UIColor *navigationBarTintColor;

/**
 The UIModalPresentationStyle for showing the update user interface when invoked
 with the update alert.
 */
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;


@end

//
//  STPTheme.h
//  Stripe
//
//  Created by Jack Flintermann on 5/3/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 STPTheme objects can be used to visually style Stripe-provided UI. See https://stripe.com/docs/mobile/ios#theming for more information.
 */
@interface STPTheme : NSObject<NSCopying>

/**
 *  The default theme used by all Stripe UI. All themable UI classes, such as `STPAddCardViewController`, have one initializer that takes a `theme` and one that does not. If you use the one that does not, the default theme will be used to customize that view controller's appearance.
 */
+ (STPTheme *)defaultTheme;

/**
 *  The primary background color of the theme. This will be used as the `backgroundColor` for any views with this theme.
 */
@property(nonatomic, copy, null_resettable)UIColor *primaryBackgroundColor;

/**
 *  The secondary background color of this theme. This will be used as the `backgroundColor` for any supplemental views inside a view with this theme - for example, a `UITableView` will set it's cells' background color to this value.
 */
@property(nonatomic, copy, null_resettable)UIColor *secondaryBackgroundColor;

/**
 *  This color is automatically derived by reducing the alpha of the `primaryBackgroundColor` and is used as a section border color in table view cells.
 */
@property(nonatomic, readonly)UIColor *tertiaryBackgroundColor;

/**
 *  This color is automatically derived by reducing the brightness of the `primaryBackgroundColor` and is used as a separator color in table view cells.
 */
@property(nonatomic, readonly)UIColor *quaternaryBackgroundColor;

/**
 *  The primary foreground color of this theme. This will be used as the text color for any important labels in a view with this theme (such as the text color for a text field that the user needs to fill out).
 */
@property(nonatomic, copy, null_resettable)UIColor *primaryForegroundColor;

/**
 *  The secondary foreground color of this theme. This will be used as the text color for any supplementary labels in a view with this theme (such as the placeholder color for a text field that the user needs to fill out).
 */
@property(nonatomic, copy, null_resettable)UIColor *secondaryForegroundColor;

/**
 *  This color is automatically derived from the `secondaryForegroundColor` with a lower alpha component, used for disabled text.
 */
@property(nonatomic, readonly)UIColor *tertiaryForegroundColor;

/**
 *  The accent color of this theme - it will be used for any buttons and other elements on a view that are important to highlight.
 */
@property(nonatomic, copy, null_resettable)UIColor *accentColor;

/**
 *  The error color of this theme - it will be used for rendering any error messages or views.
 */
@property(nonatomic, copy, null_resettable)UIColor *errorColor;

/**
 *  The font to be used for all views using this theme. Make sure to select an appropriate size.
 */
@property(nonatomic, copy, null_resettable)UIFont  *font;

/**
 *  The medium-weight font to be used for all bold text in views using this theme. Make sure to select an appropriate size.
 */
@property(nonatomic, copy, null_resettable)UIFont  *emphasisFont;

/**
 *  This font is automatically derived from the font, with a slightly lower point size, and will be used for supplementary labels.
 */
@property(nonatomic, readonly)UIFont  *smallFont;

/**
 *  This font is automatically derived from the font, with a larger point size, and will be used for large labels such as SMS code entry.
 */
@property(nonatomic, readonly)UIFont  *largeFont;

@end

NS_ASSUME_NONNULL_END

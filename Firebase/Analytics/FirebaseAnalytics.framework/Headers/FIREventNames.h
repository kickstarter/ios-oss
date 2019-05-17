/// @file FIREventNames.h
///
/// Predefined event names.
///
/// An Event is an important occurrence in your app that you want to measure. You can report up to
/// 500 different types of Events per app and you can associate up to 25 unique parameters with each
/// Event type. Some common events are suggested below, but you may also choose to specify custom
/// Event types that are associated with your specific app. Each event type is identified by a
/// unique name. Event names can be up to 32 characters long, may only contain alphanumeric
/// characters and underscores ("_"), and must start with an alphabetic character. The "firebase_"
/// prefix is reserved and should not be used.

/// Add Payment Info event. This event signifies that a user has submitted their payment information
/// to your app.
static NSString *const kFIREventAddPaymentInfo = @"add_payment_info";

/// E-Commerce Add To Cart event. This event signifies that an item was added to a cart for
/// purchase. Add this event to a funnel with kFIREventEcommercePurchase to gauge the effectiveness
/// of your checkout process. Note: If you supply the {@link kFIRParameterValue} parameter, you must
/// also supply the {@link kFIRParameterCurrency} parameter so that revenue metrics can be computed
/// accurately. Params:
///
/// <ul>
///     <li>{@link kFIRParameterQuantity} (signed 64-bit integer as NSNumber)</li>
///     <li>{@link kFIRParameterItemID} (NSString)</li>
///     <li>{@link kFIRParameterItemName} (NSString)</li>
///     <li>{@link kFIRParameterItemCategory} (NSString)</li>
///     <li>{@link kFIRParameterItemLocationID} (NSString) (optional)</li>
///     <li>{@link kFIRParameterPrice} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterOrigin} (NSString) (optional)</li>
///     <li>{@link kFIRParameterDestination} (NSString) (optional)</li>
///     <li>{@link kFIRParameterStartDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterEndDate} (NSString) (optional)</li>
/// </ul>
static NSString *const kFIREventAddToCart = @"add_to_cart";

/// E-Commerce Add To Wishlist event. This event signifies that an item was added to a wishlist.
/// Use this event to identify popular gift items in your app. Note: If you supply the
/// {@link kFIRParameterValue} parameter, you must also supply the {@link kFIRParameterCurrency}
/// parameter so that revenue metrics can be computed accurately. Params:
///
/// <ul>
///     <li>{@link kFIRParameterQuantity} (signed 64-bit integer as NSNumber)</li>
///     <li>{@link kFIRParameterItemID} (NSString)</li>
///     <li>{@link kFIRParameterItemName} (NSString)</li>
///     <li>{@link kFIRParameterItemCategory} (NSString)</li>
///     <li>{@link kFIRParameterItemLocationID} (NSString) (optional)</li>
///     <li>{@link kFIRParameterPrice} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
/// </ul>
static NSString *const kFIREventAddToWishlist = @"add_to_wishlist";

/// App Open event. By logging this event when an App is moved to the foreground, developers can
/// understand how often users leave and return during the course of a Session. Although Sessions
/// are automatically reported, this event can provide further clarification around the continuous
/// engagement of app-users.
static NSString *const kFIREventAppOpen = @"app_open";

/// E-Commerce Begin Checkout event. This event signifies that a user has begun the process of
/// checking out. Add this event to a funnel with your kFIREventEcommercePurchase event to gauge the
/// effectiveness of your checkout process. Note: If you supply the {@link kFIRParameterValue}
/// parameter, you must also supply the {@link kFIRParameterCurrency} parameter so that revenue
/// metrics can be computed accurately. Params:
///
/// <ul>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterTransactionID} (NSString) (optional)</li>
///     <li>{@link kFIRParameterStartDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterEndDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterNumberOfNights} (signed 64-bit integer as NSNumber) (optional) for
///         hotel bookings</li>
///     <li>{@link kFIRParameterNumberOfRooms} (signed 64-bit integer as NSNumber) (optional) for
///         hotel bookings</li>
///     <li>{@link kFIRParameterNumberOfPassengers} (signed 64-bit integer as NSNumber) (optional)
///         for travel bookings</li>
///     <li>{@link kFIRParameterOrigin} (NSString) (optional)</li>
///     <li>{@link kFIRParameterDestination} (NSString) (optional)</li>
///     <li>{@link kFIRParameterTravelClass} (NSString) (optional) for travel bookings</li>
/// </ul>
static NSString *const kFIREventBeginCheckout = @"begin_checkout";

/// E-Commerce Purchase event. This event signifies that an item was purchased by a user. Note:
/// This is different from the in-app purchase event, which is reported automatically for App
/// Store-based apps. Note: If you supply the {@link kFIRParameterValue} parameter, you must also
/// supply the {@link kFIRParameterCurrency} parameter so that revenue metrics can be computed
/// accurately. Params:
///
/// <ul>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterTransactionID} (NSString) (optional)</li>
///     <li>{@link kFIRParameterTax} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterShipping} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCoupon} (NSString) (optional)</li>
///     <li>{@link kFIRParameterLocation} (NSString) (optional)</li>
///     <li>{@link kFIRParameterStartDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterEndDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterNumberOfNights} (signed 64-bit integer as NSNumber) (optional) for
///         hotel bookings</li>
///     <li>{@link kFIRParameterNumberOfRooms} (signed 64-bit integer as NSNumber) (optional) for
///         hotel bookings</li>
///     <li>{@link kFIRParameterNumberOfPassengers} (signed 64-bit integer as NSNumber) (optional)
///         for travel bookings</li>
///     <li>{@link kFIRParameterOrigin} (NSString) (optional)</li>
///     <li>{@link kFIRParameterDestination} (NSString) (optional)</li>
///     <li>{@link kFIRParameterTravelClass} (NSString) (optional) for travel bookings</li>
/// </ul>
static NSString *const kFIREventEcommercePurchase = @"ecommerce_purchase";

/// Generate Lead event. Log this event when a lead has been generated in the app to understand the
/// efficacy of your install and re-engagement campaigns. Note: If you supply the
/// {@link kFIRParameterValue} parameter, you must also supply the {@link kFIRParameterCurrency}
/// parameter so that revenue metrics can be computed accurately. Params:
///
/// <ul>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
/// </ul>
static NSString *const kFIREventGenerateLead = @"generate_lead";

/// Join Group event. Log this event when a user joins a group such as a guild, team or family. Use
/// this event to analyze how popular certain groups or social features are in your app. Params:
///
/// <ul>
///     <li>{@link kFIRParameterGroupID} (NSString)</li>
/// </ul>
static NSString *const kFIREventJoinGroup = @"join_group";

/// Level Up event. This event signifies that a player has leveled up in your gaming app. It can
/// help you gauge the level distribution of your userbase and help you identify certain levels that
/// are difficult to pass. Params:
///
/// <ul>
///     <li>{@link kFIRParameterLevel} (signed 64-bit integer as NSNumber)</li>
///     <li>{@link kFIRParameterCharacter} (NSString) (optional)</li>
/// </ul>
static NSString *const kFIREventLevelUp = @"level_up";

/// Login event. Apps with a login feature can report this event to signify that a user has logged
/// in.
static NSString *const kFIREventLogin = @"login";

/// Post Score event. Log this event when the user posts a score in your gaming app. This event can
/// help you understand how users are actually performing in your game and it can help you correlate
/// high scores with certain audiences or behaviors. Params:
///
/// <ul>
///     <li>{@link kFIRParameterScore} (signed 64-bit integer as NSNumber)</li>
///     <li>{@link kFIRParameterLevel} (signed 64-bit integer as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCharacter} (NSString) (optional)</li>
/// </ul>
static NSString *const kFIREventPostScore = @"post_score";

/// Present Offer event. This event signifies that the app has presented a purchase offer to a user.
/// Add this event to a funnel with the kFIREventAddToCart and kFIREventEcommercePurchase to gauge
/// your conversion process. Note: If you supply the {@link kFIRParameterValue} parameter, you must
/// also supply the {@link kFIRParameterCurrency} parameter so that revenue metrics can be computed
/// accurately. Params:
///
/// <ul>
///     <li>{@link kFIRParameterQuantity} (signed 64-bit integer as NSNumber)</li>
///     <li>{@link kFIRParameterItemID} (NSString)</li>
///     <li>{@link kFIRParameterItemName} (NSString)</li>
///     <li>{@link kFIRParameterItemCategory} (NSString)</li>
///     <li>{@link kFIRParameterItemLocationID} (NSString) (optional)</li>
///     <li>{@link kFIRParameterPrice} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
/// </ul>
static NSString *const kFIREventPresentOffer = @"present_offer";

/// E-Commerce Purchase Refund event. This event signifies that an item purchase was refunded.
/// Note: If you supply the {@link kFIRParameterValue} parameter, you must also supply the
/// {@link kFIRParameterCurrency} parameter so that revenue metrics can be computed accurately.
/// Params:
///
/// <ul>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterTransactionID} (NSString) (optional)</li>
/// </ul>
static NSString *const kFIREventPurchaseRefund = @"purchase_refund";

/// Search event. Apps that support search features can use this event to contextualize search
/// operations by supplying the appropriate, corresponding parameters. This event can help you
/// identify the most popular content in your app. Params:
///
/// <ul>
///     <li>{@link kFIRParameterSearchTerm} (NSString)</li>
///     <li>{@link kFIRParameterStartDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterEndDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterNumberOfNights} (signed 64-bit integer as NSNumber) (optional) for
///         hotel bookings</li>
///     <li>{@link kFIRParameterNumberOfRooms} (signed 64-bit integer as NSNumber) (optional) for
///         hotel bookings</li>
///     <li>{@link kFIRParameterNumberOfPassengers} (signed 64-bit integer as NSNumber) (optional)
///         for travel bookings</li>
///     <li>{@link kFIRParameterOrigin} (NSString) (optional)</li>
///     <li>{@link kFIRParameterDestination} (NSString) (optional)</li>
///     <li>{@link kFIRParameterTravelClass} (NSString) (optional) for travel bookings</li>
/// </ul>
static NSString *const kFIREventSearch = @"search";

/// Select Content event. This general purpose event signifies that a user has selected some content
/// of a certain type in an app. The content can be any object in your app. This event can help you
/// identify popular content and categories of content in your app. Params:
///
/// <ul>
///     <li>{@link kFIRParameterContentType} (NSString)</li>
///     <li>{@link kFIRParameterItemID} (NSString)</li>
/// </ul>
static NSString *const kFIREventSelectContent = @"select_content";

/// Share event. Apps with social features can log the Share event to identify the most viral
/// content. Params:
///
/// <ul>
///     <li>{@link kFIRParameterContentType} (NSString)</li>
///     <li>{@link kFIRParameterItemID} (NSString)</li>
/// </ul>
static NSString *const kFIREventShare = @"share";

/// Sign Up event. This event indicates that a user has signed up for an account in your app. The
/// parameter signifies the method by which the user signed up. Use this event to understand the
/// different behaviors between logged in and logged out users. Params:
///
/// <ul>
///     <li>{@link kFIRParameterSignUpMethod} (NSString)</li>
/// </ul>
static NSString *const kFIREventSignUp = @"sign_up";

/// Spend Virtual Currency event. This event tracks the sale of virtual goods in your app and can
/// help you identify which virtual goods are the most popular objects of purchase. Params:
///
/// <ul>
///     <li>{@link kFIRParameterItemName} (NSString)</li>
///     <li>{@link kFIRParameterVirtualCurrencyName} (NSString)</li>
///     <li>{@link kFIRParameterValue} (signed 64-bit integer or double as NSNumber)</li>
/// </ul>
static NSString *const kFIREventSpendVirtualCurrency = @"spend_virtual_currency";

/// Tutorial Begin event. This event signifies the start of the on-boarding process in your app. Use
/// this in a funnel with kFIREventTutorialComplete to understand how many users complete this
/// process and move on to the full app experience.
static NSString *const kFIREventTutorialBegin = @"tutorial_begin";

/// Tutorial End event. Use this event to signify the user's completion of your app's on-boarding
/// process. Add this to a funnel with kFIREventTutorialBegin to gauge the completion rate of your
/// on-boarding process.
static NSString *const kFIREventTutorialComplete = @"tutorial_complete";

/// Unlock Achievement event. Log this event when the user has unlocked an achievement in your
/// game. Since achievements generally represent the breadth of a gaming experience, this event can
/// help you understand how many users are experiencing all that your game has to offer. Params:
///
/// <ul>
///     <li>{@link kFIRParameterAchievementID} (NSString)</li>
/// </ul>
static NSString *const kFIREventUnlockAchievement = @"unlock_achievement";

/// View Item event. This event signifies that some content was shown to the user. This content may
/// be a product, a webpage or just a simple image or text. Use the appropriate parameters to
/// contextualize the event. Use this event to discover the most popular items viewed in your app.
/// Note: If you supply the {@link kFIRParameterValue} parameter, you must also supply the
/// {@link kFIRParameterCurrency} parameter so that revenue metrics can be computed accurately.
/// Params:
///
/// <ul>
///     <li>{@link kFIRParameterItemID} (NSString)</li>
///     <li>{@link kFIRParameterItemName} (NSString)</li>
///     <li>{@link kFIRParameterItemCategory} (NSString)</li>
///     <li>{@link kFIRParameterItemLocationID} (NSString) (optional)</li>
///     <li>{@link kFIRParameterPrice} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterQuantity} (signed 64-bit integer as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterCurrency} (NSString) (optional)</li>
///     <li>{@link kFIRParameterValue} (double as NSNumber) (optional)</li>
///     <li>{@link kFIRParameterStartDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterEndDate} (NSString) (optional)</li>
///     <li>{@link kFIRParameterFlightNumber} (NSString) (optional) for travel bookings</li>
///     <li>{@link kFIRParameterNumberOfPassengers} (signed 64-bit integer as NSNumber) (optional)
///         for travel bookings</li>
///     <li>{@link kFIRParameterNumberOfNights} (signed 64-bit integer as NSNumber) (optional) for
///         travel bookings</li>
///     <li>{@link kFIRParameterNumberOfRooms} (signed 64-bit integer as NSNumber) (optional) for
///         travel bookings</li>
///     <li>{@link kFIRParameterOrigin} (NSString) (optional)</li>
///     <li>{@link kFIRParameterDestination} (NSString) (optional)</li>
///     <li>{@link kFIRParameterSearchTerm} (NSString) (optional) for travel bookings</li>
///     <li>{@link kFIRParameterTravelClass} (NSString) (optional) for travel bookings</li>
/// </ul>
static NSString *const kFIREventViewItem = @"view_item";

/// View Item List event. Log this event when the user has been presented with a list of items of a
/// certain category. Params:
///
/// <ul>
///     <li>{@link kFIRParameterItemCategory} (NSString)</li>
/// </ul>
static NSString *const kFIREventViewItemList = @"view_item_list";

/// View Search Results event. Log this event when the user has been presented with the results of a
/// search. Params:
///
/// <ul>
///     <li>{@link kFIRParameterSearchTerm} (NSString)</li>
/// </ul>
static NSString *const kFIREventViewSearchResults = @"view_search_results";

import Foundation
@testable import Kickstarter_Framework
import Library

AppEnvironment.replaceCurrentEnvironment(mainBundle: NSBundle(identifier: "com.Kickstarter-iOS-Framework")!)

AppEnvironment.replaceCurrentEnvironment(language: .en)
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available_many(
  backer_count: Format.wholeNumber(1234)
)

AppEnvironment.replaceCurrentEnvironment(language: .es, locale: NSLocale(localeIdentifier: "es"))
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available_many(
  backer_count: Format.wholeNumber(1234)
)

AppEnvironment.replaceCurrentEnvironment(language: .fr, locale: NSLocale(localeIdentifier: "fr"))
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available_many(
  backer_count: Format.wholeNumber(1234)
)

AppEnvironment.replaceCurrentEnvironment(language: .de, locale: NSLocale(localeIdentifier: "de"))
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available_many(
  backer_count: Format.wholeNumber(1234)
)

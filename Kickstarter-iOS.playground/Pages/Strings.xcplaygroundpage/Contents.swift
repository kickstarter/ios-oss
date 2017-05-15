import Foundation
@testable import Kickstarter_Framework
import Library

AppEnvironment.replaceCurrentEnvironment(mainBundle: Bundle.framework)

AppEnvironment.replaceCurrentEnvironment(language: .en)
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available(
  backer_count: 1234
)

AppEnvironment.replaceCurrentEnvironment(language: .es, locale: Locale(identifier: "es"))
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available(
  backer_count: 1234
)

AppEnvironment.replaceCurrentEnvironment(language: .fr, locale: Locale(identifier: "fr"))
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available(
  backer_count: 1234
)

AppEnvironment.replaceCurrentEnvironment(language: .de, locale: Locale(identifier: "de"))
Strings.activity_empty_state_logged_in_message()
Strings.dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available(
  backer_count: 1234
)

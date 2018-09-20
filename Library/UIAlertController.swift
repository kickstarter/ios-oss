import class UIKit.UIAlertController
import class UIKit.UIAlertAction
import FBSDKLoginKit
import Foundation
import KsApi

public extension UIAlertController {

  public static func alertController(forError error: AlertError) -> UIAlertController {
    switch error {
    case let .genericError(message):
      return self.genericError(message)
    case .facebookTokenFail:
      return self.facebookTokenFail()
    case let .facebookLoginAttemptFail(error):
      return self.facebookLoginAttemptFail(error)
    case let .genericFacebookError(envelope):
      return self.genericFacebookError(envelope)
    case let .facebookConnectAccountTaken(envelope):
      return self.facebookConnectAccountTaken(envelope)
    case let .facebookConnectEmailTaken(envelope):
      return self.facebookConnectEmailTaken(envelope)
    }
  }

  public static func alert(_ title: String? = nil,
                           message: String? = nil,
                           handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: handler
      )
    )

    return alertController
  }

  public static func genericError(_ message: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.general_error_oops(),
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func games(subscribeHandler: @escaping ((UIAlertAction) -> Void))
    -> UIAlertController {
    let alertController = UIAlertController(
      title: nil,
      message: Strings.project_checkout_games_alert_want_the_coolest_games_delivered_to_your_inbox(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_games_alert_yes_please(),
        style: .default,
        handler: subscribeHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_games_alert_no_thanks(),
        style: .default,
        handler: nil
      )
    )

    return alertController
  }

  public static func rating(yesHandler: @escaping ((UIAlertAction) -> Void),
                            remindHandler: @escaping ((UIAlertAction) -> Void),
                            noHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.profile_settings_rating_title() ,
      message: Strings.profile_settings_rating_message() ,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.profile_settings_rating_option_rate_now() ,
        style: .default,
        handler: yesHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.profile_settings_rating_option_remind_later() ,
        style: .default,
        handler: remindHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.profile_settings_rating_option_no_thanks() ,
        style: .default,
        handler: noHandler
      )
    )

    return alertController
  }

  public static func newsletterOptIn(_ newsletter: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.profile_settings_newsletter_opt_in_title(),
      message: Strings.profile_settings_newsletter_opt_in_message(newsletter: newsletter),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func projectCopiedToPasteboard(projectURL url: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: nil,
      message: Strings.project_checkout_share_link_the_project_url_has_been_copied_to_your_clipboard(
        project_url: url
        ),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_share_link_OK(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func updateCopiedToPasteboard(updateURL url: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: nil,
      message: Strings.project_checkout_share_link_the_update_url_has_been_copied_to_your_clipboard(
        update_url: url
        ),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_share_link_OK(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func confirmFollowAllFriends(
    friendsCount: Int,
    yesHandler: @escaping ((UIAlertAction) -> Void),
    noHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {

    let alertController = UIAlertController(
      title: Strings.social_following_stats_button_follow_all_friends(remote_friends_count: friendsCount),
      message: Strings.social_following_nice_youre_about_to_follow_all_friends(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_navigation_buttons_ok(),
        style: .default,
        handler: yesHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_navigation_buttons_cancel(),
        style: .cancel,
        handler: noHandler
      )
    )

    return alertController
  }

  public static func turnOffPrivacyFollowing(
    cancelHandler: @escaping ((UIAlertAction) -> Void),
    turnOffHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {

    let alertController = UIAlertController(
      title: Strings.Are_you_sure(),
      message: Strings.If_you_turn_following_off(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.Yes_turn_off(),
        style: .destructive,
        handler: turnOffHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_navigation_buttons_cancel(),
        style: .cancel,
        handler: cancelHandler
      )
    )

    return alertController
  }

  public static func followingPrivacyInfo() -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.Following(),
      message: Strings.When_following_is_on_you_can_follow_the_acticity_of_others(),
      preferredStyle: .alert)

    alertController.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookTokenFail() -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_invalid_token_title(),
      message: Strings.login_tout_errors_facebook_invalid_token_message(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookLoginAttemptFail(_ error: NSError) -> UIAlertController {
    let alertController = UIAlertController(
      title: error.userInfo[FBSDKErrorLocalizedTitleKey] as? String ??
        Strings.login_tout_errors_facebook_settings_disabled_title(),
      message: error.userInfo[FBSDKErrorLocalizedDescriptionKey] as? String ??
        Strings.login_tout_errors_facebook_settings_disabled_message(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func genericFacebookError(_ envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_generic_error_title(),
      message: envelope.errorMessages.first ?? Strings.login_tout_errors_facebook_generic_error_message(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookConnectAccountTaken(_ envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_generic_error_title(),
      message: envelope.errorMessages.first ??
        Strings.This_facebook_account_is_already_linked_to_another_Kickstarter_user(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookConnectEmailTaken(_ envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_generic_error_title(),
      message: envelope.errorMessages.first ??
        Strings.The_email_associated_with_this_Facebook_account_is_already_registered(),
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }
}

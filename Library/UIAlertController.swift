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

  public static func alert(title: String? = nil,
                           message: String? = nil,
                           handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: handler
      )
    )

    return alertController
  }

  public static func genericError(message: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.general_error_oops(),
      message: message,
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func games(subscribeHandler subscribeHandler: ((UIAlertAction) -> Void))
    -> UIAlertController {
    let alertController = UIAlertController(
      title: nil,
      message: Strings.project_checkout_games_alert_want_the_coolest_games_delivered_to_your_inbox(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_games_alert_yes_please(),
        style: .Default,
        handler: subscribeHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_games_alert_no_thanks(),
        style: .Default,
        handler: nil
      )
    )

    return alertController
  }

  public static func rating(yesHandler yesHandler: ((UIAlertAction) -> Void),
                            remindHandler: ((UIAlertAction) -> Void),
                            noHandler: ((UIAlertAction) -> Void)) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.profile_settings_rating_title() ,
      message: Strings.profile_settings_rating_message() ,
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.profile_settings_rating_option_rate_now() ,
        style: .Default,
        handler: yesHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.profile_settings_rating_option_remind_later() ,
        style: .Default,
        handler: remindHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.profile_settings_rating_option_no_thanks() ,
        style: .Default,
        handler: noHandler
      )
    )

    return alertController
  }

  public static func newsletterOptIn(newsletter: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.profile_settings_newsletter_opt_in_title(),
      message: Strings.profile_settings_newsletter_opt_in_message(newsletter: newsletter),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
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
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_share_link_OK(),
        style: .Cancel,
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
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.project_checkout_share_link_OK(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func confirmFollowAllFriends(friendsCount friendsCount: Int,
                                             yesHandler: ((UIAlertAction) -> Void),
                                             noHandler: ((UIAlertAction) -> Void)) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.social_following_stats_button_follow_all_friends(remote_friends_count: friendsCount),
      message: Strings.social_following_nice_youre_about_to_follow_all_friends(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_navigation_buttons_ok(),
        style: .Default,
        handler: yesHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_navigation_buttons_cancel(),
        style: .Cancel,
        handler: noHandler
      )
    )

    return alertController
  }

  public static func facebookTokenFail() -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_invalid_token_title(),
      message: Strings.login_tout_errors_facebook_invalid_token_message(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookLoginAttemptFail(error: NSError) -> UIAlertController {
    let alertController = UIAlertController(
      title: error.userInfo[FBSDKErrorLocalizedTitleKey] as? String ??
        Strings.login_tout_errors_facebook_settings_disabled_title(),
      message: error.userInfo[FBSDKErrorLocalizedDescriptionKey] as? String ??
        Strings.login_tout_errors_facebook_settings_disabled_message(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func genericFacebookError(envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_generic_error_title(),
      message: envelope.errorMessages.first ?? Strings.login_tout_errors_facebook_generic_error_message(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookConnectAccountTaken(envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_generic_error_title(),
      message: envelope.errorMessages.first ??
        Strings.This_facebook_account_is_already_linked_to_another_Kickstarter_user(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookConnectEmailTaken(envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: Strings.login_tout_errors_facebook_generic_error_title(),
      message: envelope.errorMessages.first ??
        Strings.The_email_associated_with_this_Facebook_account_is_already_registered(),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: Strings.general_alert_buttons_ok(),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }
}

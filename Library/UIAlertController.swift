import class UIKit.UIAlertController
import class UIKit.UIAlertAction
import FBSDKLoginKit
import Foundation
import KsApi

public enum AlertError {
  case genericError(message: String)
  case facebookTokenFail
  case facebookLoginAttemptFail(error: NSError)
  case genericFacebookError(envelope: ErrorEnvelope)
  case facebookConnectAccountTaken(envelope: ErrorEnvelope)
  case facebookConnectEmailTaken(envelope: ErrorEnvelope)
}

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
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: handler
      )
    )

    return alertController
  }

  public static func genericError(message: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(key: "general.error.oops", defaultValue: "Oops!"),
      message: message,
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
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
      message: localizedString(
        key: "project.checkout.games_alert.want_the_coolest_games_delivered_to_your_inbox",
        defaultValue: "Want the coolest games delivered to your inbox? " +
          "Our Games team has a newsletter just for you."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "project.checkout.games_alert.yes_please", defaultValue: "Yes please!"),
        style: .Default,
        handler: subscribeHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "project.checkout.games_alert.no_thanks", defaultValue: "No thanks."),
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
      title: localizedString(key: "profile.settings.rating.title", defaultValue: "Show us some love"),
      message: localizedString(
        key: "profile.settings.rating.message",
        defaultValue: "Thanks for using the Kickstarter app.\nIf you have a moment, " +
          "would you mind rating your experience?\nWe'd appreciate it!"),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "profile.settings.rating.option.rate_now", defaultValue: "Rate It Now"),
        style: .Default,
        handler: yesHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(
          key: "profile.settings.rating.option.remind_later",
          defaultValue: "Remind Me Later"),
        style: .Default,
        handler: remindHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "profile.settings.rating.option.no_thanks", defaultValue: "No, Thanks"),
        style: .Default,
        handler: noHandler
      )
    )

    return alertController
  }

  public static func newsletterOptIn(newsletter: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(
        key: "profile.settings.newsletter.opt_in.title",
        defaultValue: "One final step!"),
      message: localizedString(
        key: "profile.settings.newsletter.opt_in.message",
        defaultValue: "We've sent a confirmation email to the address associated with your account! " +
          "Please check your email in order to confirm that you'd like to subscribe to %{newsletter}.",
        count: nil,
        substitutions: ["newsletter": newsletter]),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func projectCopiedToPasteboard(projectURL url: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: nil,
      message: localizedString(
        key: "project.checkout.share.link.the_project_url_has_been_copied_to_your_clipboard",
        defaultValue: "The projects's URL has been copied to your clipboard:\n\n%{project_url}",
        count: nil,
        substitutions: ["project_url": url]),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "project.checkout.share.link.OK", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func updateCopiedToPasteboard(updateURL url: String) -> UIAlertController {
    let alertController = UIAlertController(
      title: nil,
      message: localizedString(
        key: "project.checkout.share.link.the_update_url_has_been_copied_to_your_clipboard",
        defaultValue: "The update's URL has been copied to your clipboard:\n\n%{update_url}",
        count: nil,
        substitutions: ["update_url": url]),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "project.checkout.share.link.OK", defaultValue: "OK"),
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
      title: localizedString(
        key: "social_following.stats.button.follow_all_friends",
        defaultValue: "Follow all %{remote_friends_count} friends",
        count: friendsCount,
        substitutions: ["remote_friends_count": "\(friendsCount)"]),
      message: localizedString(
        key: "social_following.nice_youre_about_to_follow_all_friends",
        defaultValue: "Nice! You're about to follow all of your friends."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.navigation.buttons.ok", defaultValue: "OK"),
        style: .Default,
        handler: yesHandler
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.navigation.buttons.cancel", defaultValue: "Cancel"),
        style: .Cancel,
        handler: noHandler
      )
    )

    return alertController
  }

  public static func facebookTokenFail() -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(
        key: "login_tout.errors.facebook.invalid_token.title",
        defaultValue: "Facebook login"),
      message: localizedString(
        key: "login_tout.errors.facebook.invalid_token.message",
        defaultValue: "There was a problem logging you in with Facebook.\n\nThis is commonly fixed " +
        "by going to iOS Settings > Facebook and toggling access for Kickstarter."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookLoginAttemptFail(error: NSError) -> UIAlertController {
    let alertController = UIAlertController(
      title: error.userInfo[FBSDKErrorLocalizedTitleKey] as? String ??
        localizedString(key: "login_tout.errors.facebook.settings_disabled.title",
          defaultValue: "Permission denied"),
      message: error.userInfo[FBSDKErrorLocalizedDescriptionKey] as? String ??
        localizedString(key: "login_tout.errors.facebook.settings_disabled.message",
          defaultValue: "It seems that you have denied Kickstarter access to your Facebook account. "
            + "Please go to Settings > Facebook to enable access."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func genericFacebookError(envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(key: "login_tout.errors.facebook.generic_error.title",
        defaultValue: "Facebook login"),
      message: envelope.errorMessages.first ??
        localizedString(key: "login_tout.errors.facebook.generic_error.message",
          defaultValue: "Couldn't log into Facebook."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookConnectAccountTaken(envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(key: "login_tout.errors.facebook.generic_error.title",
        defaultValue: "Facebook login"),
      message: envelope.errorMessages.first ??
        localizedString(key: "login_tout.errors.facebook.account_taken.message",
          defaultValue: "This Facebook account is already linked to another Kickstarter user."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }

  public static func facebookConnectEmailTaken(envelope: ErrorEnvelope) -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(key: "login_tout.errors.facebook.generic_error.title",
        defaultValue: "Facebook login"),
      message: envelope.errorMessages.first ??
        localizedString(key: "login_tout.errors.facebook.email_taken.message",
          defaultValue: "The email associated with this Facebook account is already registered " +
          "to another Kickstarter user."),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: localizedString(key: "general.alert.buttons.ok", defaultValue: "OK"),
        style: .Cancel,
        handler: nil
      )
    )

    return alertController
  }
}

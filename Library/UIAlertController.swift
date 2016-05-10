import class UIKit.UIAlertController
import class UIKit.UIAlertAction

public extension UIAlertController {

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

  public static func games(subscribeHandler: ((UIAlertAction) -> Void)) -> UIAlertController {
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

  public static func rating(yesHandler: ((UIAlertAction) -> Void),
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

  public static func newsletterOptIn(newsletter: String,
                                     environment: Environment = AppEnvironment.current) -> UIAlertController {
    let alertController = UIAlertController(
      title: localizedString(
        key: "profile.settings.newsletter.opt_in.title",
        defaultValue: "One final step!"),
      message: localizedString(
        key: "profile.settings.newsletter.opt_in.message",
        defaultValue: "We've sent a confirmation email to the address associated with your account! " +
          "Please check your email in order to confirm that you'd like to subscribe to %{newsletter}.",
        count: nil,
        substitutions: ["newsletter": newsletter],
        env: environment),
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

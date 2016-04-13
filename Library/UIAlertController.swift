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
}

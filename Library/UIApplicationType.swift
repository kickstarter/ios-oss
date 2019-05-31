import UIKit

// swiftlint:disable line_length
public protocol UIApplicationType {
  var applicationIconBadgeNumber: Int { get }
  func canOpenURL(_ url: URL) -> Bool
  func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?)
}

// swiftlint:enable line_length

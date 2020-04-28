import UIKit

public protocol UIApplicationType {
  var applicationIconBadgeNumber: Int { get }
  func canOpenURL(_ url: URL) -> Bool
  func open(
    _ url: URL,
    options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?
  )
}

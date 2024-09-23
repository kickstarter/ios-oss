import UIKit

public protocol UIApplicationType {
  var applicationIconBadgeNumber: Int { get }
  func canOpenURL(_ url: URL) -> Bool
  #if compiler(>=6.0) // Compiler flag for Xcode >= 16
  func open(
    _ url: URL,
    options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?
  )
  #else
  func open(
    _ url: URL,
    options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?
  )
  #endif
}

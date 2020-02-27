import UIKit

public final class NavigationController: UINavigationController {
  override public var preferredStatusBarStyle: UIStatusBarStyle {
    self.topViewController?.preferredStatusBarStyle ?? UIApplication.shared.statusBarStyle
  }
}

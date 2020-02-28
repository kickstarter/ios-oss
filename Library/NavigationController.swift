import UIKit

public final class NavigationController: UINavigationController {
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    self.topViewController?.preferredStatusBarStyle ?? UIApplication.shared.statusBarStyle
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return self.topViewController?.supportedInterfaceOrientations ?? .all
  }
}

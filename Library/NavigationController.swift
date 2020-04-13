import Prelude
import UIKit

public final class NavigationController: UINavigationController {
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    self.topViewController?.preferredStatusBarStyle ?? UIApplication.shared.statusBarStyle
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return self.topViewController?.supportedInterfaceOrientations ?? .all
  }
}

extension UINavigationController {
  public func configureTransparentNavigationBar() {
    _ = self.navigationBar
      |> transparentNavigationBarStyle

    self.navigationBar.setBackgroundImage(UIImage(), for: .default)
  }
}

private let transparentNavigationBarStyle: NavigationBarStyle = { navBar in
  navBar
    ?|> \.backgroundColor .~ .clear
    ?|> \.shadowImage .~ UIImage()
    ?|> \.isTranslucent .~ true
}

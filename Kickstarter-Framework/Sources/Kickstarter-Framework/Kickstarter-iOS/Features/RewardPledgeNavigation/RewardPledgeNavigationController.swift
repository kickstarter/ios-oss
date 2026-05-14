import KDS
import Library
import UIKit

public extension UINavigationBarAppearance {
  /// Configures the appearance with an opaque white bar for iOS 18, and a liquid glass transparent bar for iOS 26+.
  func configureForPledgeFlow() {
    if #available(iOS 26, *) {
      self.configureWithDefaultBackground()
    } else {
      self.configureWithOpaqueBackground()
      self.shadowImage = UIImage()
      self.backgroundColor = Colors.Background.Surface.primary.uiColor()
    }
  }
}

public extension UIViewController {
  /// Configures the `navigationItem` with an opaque white bar for iOS 18, and a liquid glass transparent bar for iOS 26+.
  func configureNavigationBarForPledgeFlow() {
    let appearance = UINavigationBarAppearance()
    appearance.configureForPledgeFlow()

    self.navigationItem.standardAppearance = appearance
    self.navigationItem.scrollEdgeAppearance = appearance
  }
}

final class RewardPledgeNavigationController: UINavigationController {
  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationBar.standardAppearance = self.navigationBarAppearance
    self.navigationBar.scrollEdgeAppearance = self.navigationBarAppearance
  }

  private var navigationBarAppearance: UINavigationBarAppearance {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureForPledgeFlow()
    return navBarAppearance
  }
}

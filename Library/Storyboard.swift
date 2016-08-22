import UIKit

public enum Storyboard: String {
  case Activity
  case Backing
  case Checkout
  case Comments
  case Dashboard
  case DashboardProjectsDrawer
  case Discovery
  case Friends
  case Help
  case LaunchScreen
  case Login
  case Main
  case Messages
  case Profile
  case ProjectActivity
  case ProjectMagazine
  case Search
  case Settings
  case Thanks
  case Update
  case UpdateDraft
  case Video

  public func instantiate<VC: UIViewController>(viewController: VC.Type,
                          inBundle bundle: NSBundle = .framework) -> VC {
    guard
      let vc = UIStoryboard(name: self.rawValue, bundle: NSBundle(identifier: bundle.identifier))
        .instantiateViewControllerWithIdentifier(VC.storyboardIdentifier) as? VC
      else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }

    return vc
  }
}
